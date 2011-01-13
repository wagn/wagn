class Slot
  module NoControllerHelpers
    def protect_against_forgery?
      # FIXME
      false
    end

    def logged_in?
      !(User.current_user.nil? || User.current_user.login == 'anon')
    end
  end

  cattr_accessor :max_char_count, :current_slot, :max_depth
  self.max_char_count = 200
  self.max_depth = 8
  attr_reader :card, :main_card, :main_content, :action, :template
  attr_writer :form
  attr_accessor  :options_need_save, :state, :requested_view, :js_queue_initialized,
    :position, :renderer, :form, :superslot, :char_count, :item_view, :type, :renders,
    :start_time, :skip_autosave, :config, :slot_options, :render_args, :context,
    :depth

  VIEW_ALIASES = {
    :view => :open,
    :card => :open,
    :line => :closed,
    :bare => :naked,
  }

  def initialize(card, context="main_1", action="view", template=nil, opts={} )
    @card,@context,@action,@template = card,context.to_s,action.to_s,template
    Slot.current_slot ||= self

    @template ||= begin
      t = ActionView::Base.new( CardController.view_paths, {} )
      t.helpers.send :include, CardController.master_helper_module
      t.helpers.send :include, NoControllerHelpers
      t
    end
    # FIXME: this and context should all be part of the context object, I think.
    # In any case I had to use "slot_options" rather than just options to avoid confusion with lots of
    # local variables named options.
    @slot_options = {
      :relative_content => {},
      :inclusion_view_overrides => nil,
      :params => {},
      :base => nil,
    }.merge(opts)

    @slot_options[:renderer] ||= Renderer.new(inclusion_map)
    @renderer = @slot_options[:renderer]
    @context = "main_1" unless @context =~ /\_/
    @position = @context.split('_').last
    @char_count = 0
    @subslots = []
    @state = 'view'
    @depth = - max_depth
    @renders = {}
    @js_queue_initialized = {}
    
    if card and card.is_collection? and item_param=@slot_options[:params][:item]
      @item_view = item_param if !item_param.blank?
    end
  end

  def inclusion_map
    return unless map = root.slot_options[:inclusion_view_overrides]
    VIEW_ALIASES.each_pair do |known, canonical|
      map[known] = map[canonical] if map.has_key?(canonical)
    end
    map
  end

  def subslot(card, context_base=nil, &proc)
    # Note that at this point the subslot context, and thus id, are
    # somewhat meaningless-- the subslot is only really used for tracking position.
    context_base ||= self.context
    new_position = @subslots.size + 1
    new_slot = self.class.new(card, "#{context_base}_#{new_position}", @action, @template, :renderer=>@renderer)

    new_slot.depth = @depth+1
    new_slot.state = @state
    new_slot.superslot = self
    new_slot.position = new_position

    @subslots << new_slot
    new_slot
  end

  def root
    @root ||= superslot ? superslot.root : self
  end

  def form
    @form ||= begin
      # NOTE this code is largely copied out of rails fields_for
      options = {} # do I need any? #args.last.is_a?(Hash) ? args.pop : {}
      block = Proc.new {}
      builder = options[:builder] || ActionView::Base.default_form_builder
      card.name.gsub!(/^#{Regexp.escape(root.card.name)}\+/, '+') if root.card.new_record?  ##FIXME -- need to match other relative inclusions.
      fields_for = builder.new("cards[#{card.name.pre_cgi}]", card, @template, options, block)
    end
  end

  def full_field_name(field)
    form.text_field(field).match(/name=\"([^\"]*)\"/)[1]
  end

  def js
    @js ||= SlotJavascript.new(self)
  end

  # FIXME: passing a block seems to only work in the templates and not from
  # internal slot calls, so I added the option passing internal content which
  # makes all the ugly block_given? ifs..
  def wrap(action="", args={}, content=nil)
    result, open_slot, close_slot = "","", ""

    if render_slot = args.key?(:add_slot) ? args.delete(:add_slot) : !xhr?
      case action.to_s
        when 'content';    css_class = 'transcluded'
        when 'exception';  css_class = 'exception'
        else begin
          css_class = 'card-slot '
          css_class << (action=='closed' ? 'line' : 'paragraph')
        end
      end

      css_class << " " + Wagn::Pattern.css_names( card ) if card

      attributes = {
        :cardId   => (card && card.id),
        :style    => args[:style],
        :view     => args[:view],
        :item     => args[:item],
        :base     => args[:base], # deprecated
        :class    => css_class,
        :position => UUID.new.generate.gsub(/^(\w+)0-(\w+)-(\w+)-(\w+)-(\w+)/,'\1')
      }
      open_slot, close_slot = "<div ", "</div>"

      open_slot += attributes.map{ |key,value| value && %{ #{key}="#{value}" }  }.join + '>'
    end

    return open_slot + content + close_slot if content

    if (Rails::VERSION::MAJOR >=2 && Rails::VERSION::MINOR >= 2)
      args = nil
      @template.output_buffer ||= ''   # fixes error in CardControllerTest#test_changes
    else
      args = proc.binding
    end
    @template.concat open_slot, *args
    yield(self)
    @template.concat close_slot, *args
    ""
  end

  def wrap_content( content="" )
    %{<span class="#{canonicalize_view(self.requested_view)}-content content editOnDoubleClick">} +
    content.to_s +
    %{</span>} #<!--[if IE]>&nbsp;<![endif]-->}
  end

  def wrap_main(content)
    return content if p=root.slot_options[:params] and p[:layout]=='none'
    %{<div id="main" context="main">#{content}</div>}
  end

  def render_check(action, args)
    ch_action = case
    when too_deep?;  :too_deep 
    when [:edit, :edit_in_form, :multi_edit].member?(action)
      !card.ok?(:edit) and :deny_view #should be deny_edit
    else
      !card.ok?(:read) and :deny_view
    end
    (ch_action and render_partial("views/#{ch_action}", args))
  end

  def render_deny(action, args)
    if [ :deny_view, :edit_auto, :too_slow, :too_deep, :open_missing,
         :closed_missing, :setting_missing].member?(action)
       render_partial("views/#{action}", args)
    elsif card.new_record?; return # need create check...
    else render_check(action, args) end
  end

  def canonicalize_view( view )
    view = view.to_sym
    VIEW_ALIASES[view.to_sym] || view
  end

  def too_deep?() @depth >= 0 end

  def render(action, args={})
#Rails.logger.debug "Slot(#{card.name}).render #{card.generic?} #{action} #{args.inspect}"
    self.render_args = args.clone
    denial = render_deny(action, args)
    return denial if denial
    
    result = case action = canonicalize_view(action)
      # FIXME: we can refactor out the rest of these later
      ###----------------( NAME) (FIXME move to chunks/transclude)
        when :name   ; card.name
        when :link   ; Chunk::Reference.link_render(card.name, args)

      ###----------------( SPECIAL )
        when :titled
          content_tag( :h1, fancy_title(card.name) ) + self._render_content
        when :rss_titled                                                         
          # content includes wrap  (<object>, etc.) , which breaks at least safari rss reader.
          content_tag( :h2, fancy_title(card.name) ) + self._render_open_content
        when :layout
          @main_card, mc = args.delete(:main_card), args.delete(:main_content)
          @main_content = mc.blank? ? nil : wrap_main(mc)
          expand_inclusions(card.raw_content, main_card)

        when :naked          ; _render_naked
        when :raw            ; get_raw

      ###---(  EDIT VIEWS )
        when :edit_in_form
          render_partial('views/edit_in_form', args.merge(:form=>form))

        when :blank         ; ""

	else
	  render_method = "render_#{action}"
          if respond_to?('_'+render_method.to_s)
            self.send render_method.to_sym, args
          else
            "<strong>#{card.name} - unknown card view: '#{action}' M:#{render_method.inspect}</strong>"
          end
        end

#      result ||= "" #FIMXE: wtf?
    result << javascript_tag("setupLinksAndDoubleClicks();") if args[:add_javascript]
    result.strip
  rescue Card::PermissionDenied=>e
    return "Permission error: #{e.message}"
  end

  def _render_content(args={})
    @state = 'view'
    self.requested_view = 'content'
    c = _render_naked
    c = "<span class=\"faint\">--</span>" if c.size < 10 && strip_tags(c).blank?
    wrap('content', args, wrap_content(c))
  end

  def _render_new(args={})
    wrap('', args, render_partial('views/new'))
  end

  def _render_open(args={})
    @state = :view
    self.requested_view = 'open'
    wrap('open', args, render_partial('views/open'))
  end

  def _render_closed(args={})
    @state = :line
    self.requested_view = 'closed'
    wrap('closed', args, render_partial('views/closed'))
  end

  def _render_setting(args={})
    wrap( self.requested_view = 'content', args,
          render_partial('views/setting') )
  end

  def _render_edit(args={})
    @state=:edit
    # FIXME CONTENT: the hard template test can go away when we phase out the old system.
    wrap('', args, card.content_template ?  render(:multi_edit) : content_field(slot.form))
  end

  def _render_multi_edit( args={})
    @state=:edit
    args[:add_javascript]=true
    wrap('', args, hidden_field_tag(:multi_edit, true) + _render_naked)
  end

  def _render_rss_change(args={})
    self.requested_view = 'content'
    render_partial('views/change')
  end

  def _render_change(args={})
    self.requested_view = 'content'
    wrap('content', args, w_content = render_partial('views/change'))
  end

  def _render_open_content(args={})
    card.post_render(_render_naked)
  end

  def _render_closed_content(args={})
    if card.generic?
      truncatewords_with_closing_tags( _render_naked )
    else
      render_card_partial(:line)   # in basic case: --> truncate( slot._render_open_content ))
    end
  end

  def _render_array(args={})
#Rails.logger.debug "Slot(#{card.name}).render_array T:#{card.type}  root = #{root}"
    if too_deep?
      return render_partial( 'views/too_deep' )
    end
    if card.is_collection?
      card.each_name { |name| subslot(Card.fetch_or_new(name))._render_core }.inspect
    else
      [_render_naked].inspect
    end
  end

  def _render_naked(args={})
    card.generic? ? _render_core : render_card_partial(:content)  # FIXME?: 'content' is inconsistent
  end

  def get_raw(args={})
    if card.virtual? and card.builtin?  # virtual? test will filter out cached cards (which won't respond to builtin)
      template.render :partial => "builtin/#{card.name.gsub(/\*/,'')}"
    else
      block_given? ? yield(card.raw_content||"") : card.raw_content
    end
  end

  def _render_core(args={})
    get_raw do |r_content|
      @renderer.render( slot_options[:base]||card, r_content) {|c,o| expand_card(c,o)}
    end
  end

  def expand_inclusions(content, render_card=nil)
    @renderer.render(render_card||card, content) {|c,o| expand_card(c,o)}
  end

  def expand_card(tname, options)
    return '' if (@state==:line && self.char_count > Slot.max_char_count)
    # Don't bother processing inclusion if we're already out of view

    case tname
    when '_main'
      return root.main_content if root.main_content
      tcard = root.main_card
      item  = symbolize_param(:item) and options[:item] = item
      pview = symbolize_param(:view) and options[:view] = pview
      options[:context] = 'main'
      options[:view] ||= :open
    end

    options[:view] ||= (self.context == "layout_0" ? :naked : :content)
    options[:fullname] = fullname = get_inclusion_fullname(tname,options)
    options[:showname] = tname.to_show(fullname)

    tcard ||= case
    when @state==:edit
      Card.fetch_or_new(fullname, {}, new_inclusion_card_args(options))
    when slot_options[:base].respond_to?(:name)# &&
         #slot_options[:base].name == fullname
      slot_options[:base]
    else
      Card.fetch_or_new(fullname, :skip_defaults=>true)
    end
    
    tcard.loaded_trunk=card if tname =~ /^\+/
    tcontent = process_inclusion(tcard, options)
    tcontent = resize_image_content(tcontent, options[:size]) if options[:size]
    self.char_count += (tcontent ? tcontent.length : 0) #should we strip html here?
    tname=='_main' ? wrap_main(tcontent) : tcontent
  rescue Card::PermissionDenied
    ''
  end

  def process_inclusion(tcard, options)
    subslot = subslot(tcard, options[:context])
    old_slot, Slot.current_slot = Slot.current_slot, subslot

    # set item_view;  search cards access this variable when rendering their content.
    subslot.item_view = options[:item] if options[:item]
    subslot.type = options[:type] if options[:type]

    # FIXME! need a different test here
    new_card = tcard.new_record? && !tcard.virtual?

    state = @state.to_sym
    subslot.requested_view = vmode = (options[:view] || :content).to_sym
    action = case

      when [:name, :link, :linkname].member?(vmode)  ; vmode
      #when [:name, :link, :linkname].member?(vmode)  ; raise "Should be handled in chunks"
      when :edit == state
       tcard.virtual? ? :edit_auto : :edit_in_form
      when new_card
        case
          when vmode==:raw; :blank
          when vmode==:setting   ; :setting_missing
          when state==:line      ; :closed_missing
          else                   ; :open_missing
        end
      when state==:line          ; :closed_content
      else                       ; vmode
      end
    result = subslot.render(action, options)
    Slot.current_slot = old_slot
    result
  rescue Exception=>e
    warn e.inspect
    Rails.logger.info e.inspect
    Rails.logger.debug e.backtrace.join "\n"
    %{<span class="inclusion-error">error rendering #{link_to_page tcard.name}</span>}
  end

  def get_inclusion_fullname(name,options)
    fullname = name+'' #weird.  have to do this or the tname gets busted in the options hash!!
    sob = slot_options[:base]
    context = case
    when sob; (sob.respond_to?(:name) ? sob.name : sob)
    when options[:base]=='parent'
      card.parent_name
    else
      card.name
    end
    fullname = fullname.to_absolute(context)
    fullname.gsub!('_user') { User.current_user.cardname }
    fullname = fullname.particle_names.map do |x|
      if x =~ /^_/ and root.slot_options[:params] and root.slot_options[:params][x]
        CGI.escapeHTML( root.slot_options[:params][x] )
      else x end
    end.join("+")
    fullname
  end

  def get_inclusion_content(cardname)
    parameters = root.slot_options[:relative_content]
    content = parameters[cardname.gsub(/\+/,'_')]

    # CLEANME This is a hack to get it so plus cards re-populate on failed signups
    if parameters['cards'] and card_params = parameters['cards'][cardname.gsub('+','~plus~')]
      content = card_params['content']
    end
    content if content.present?  #not sure I get why this is necessary - efm
  end

  def new_inclusion_card_args(options)
    args = { :type =>options[:type],  :permissions=>[] }
    if content=get_inclusion_content(options[:tname])
      args[:content]=content
    end
    args
  end

  def resize_image_content(content, size)
    size = (size.to_s == "full" ? "" : "_#{size}")
    content.gsub(/_medium(\.\w+\")/,"#{size}"+'\1')
  end

  def render_partial( partial, locals={} )
    @template.render(:partial=>partial, :locals=>{ :card=>card, :slot=>self }.merge(locals))
  end

  def card_partial(action)
    # FIXME: I like this method name better- maybe other calls should resolve here instead
    partial_for_action(action, card)
  end

  def render_card_partial(action, locals={})
     render_partial card_partial(action), locals
  end

  def method_missing(method_id, *args, &proc)
    if (methd = method_id.to_s) =~ /^render_/
      class_eval %{
        def #{methd}_with_check(args={})
          render_check(#{method_id.inspect}, args) || 
            send(:#{methd}_without_check, args)
        end
	alias_method #{method_id.inspect}, :_#{methd}
        alias_method_chain #{method_id.inspect}, :check
      }
      send(method_id, args[0])
    else
    # silence Rails 2.2.2 warning about binding argument to concat.  tried detecting rails 2.2
    # and removing the argument but it broken lots of integration tests.
      ActiveSupport::Deprecation.silence { @template.send(method_id, *args, &proc) }
    end
  end

  #### --------------------  additional helpers ---------------- ###
  def render_diff(card, *args)
    @renderer.render_diff(card, *args)
  end

  def notice
    # this used to access controller.notice, but as near I can tell
    # nothing ever assigns to controller.notice, so I took it away.
    # entries in flash[:notice] would be more appropriate in the page-wide
    # alert area. a quick javascript hack to have this put them there resulted in
    # odd behavior so leaving it off for now -LWH
    %{<span class="notice"></span>}
  end

  def id(area="")
    area, id = area.to_s, ""
    id << "javascript:#{get(area)}"
  end

  def parent
    "javascript:getSlotSpan(getSlotSpan(this).parentNode)"
  end

  def nested_context?
    context.split('_').length > 2
  end

  def get(area="")
    area.empty? ? "getSlotSpan(this)" : "getSlotElement(this, '#{area}')"
  end

  def selector(area="")
    "getSlotFromContext('#{context}')";
  end

  def card_id
    (card.new_record? && card.name)  ? Cardname.escape(card.name) : card.id
  end

  def editor_id(area="")
    area, eid = area.to_s, ""
    eid << context
    eid << (area.blank? ? '' : "-#{area}")
  end

  def edit_submenu(on)
    div(:class=>'submenu') do
      [[ :content,    true  ],
       [ :name,       true, ],
       [ :type,       !(card.type_template? || (card.type=='Cardtype' and ct=card.me_type and !ct.find_all_by_trash(false).empty?))],
       [ :codename,   (System.always_ok? && card.type=='Cardtype')],
       [ :inclusions, !(card.out_transclusions.empty? || card.template? || card.hard_template),         {:inclusions=>true} ]
       ].map do |key,ok,args|

        link_to_remote( key,
          { :url=>url_for("card/edit", args, key), :update => ([:name,:type,:codename].member?(key) ? id('card-body') : id) },
          :class=>(key==on ? 'on' : '')
        ) if ok
      end.compact.join
     end
  end

  def options_submenu(on)
    div(:class=>'submenu') do
      [:permissions, :settings].map do |key|
        link_to_remote( key,
          { :url=>url_for("card/options", {}, key), :update => id },
          :class=>(key==on ? 'on' : '')
        )
      end.join
    end
  end

  def paging_params
    s = {}
    if p = root.slot_options[:params]
      [:offset,:limit].each{|key| s[key] = p.delete(key)}
    end
    s[:offset] = s[:offset] ? s[:offset].to_i : 0
    s[:limit]  = s[:limit]  ? s[:limit].to_i  : (main_card? ? 50 : 20)
    s
  end

  def main_card?
    context=~/^main_\d$/
  end

  def url_for(url, args=nil, attribute=nil)
    # recently changed URI.escape to CGI.escape to address question mark issue, but I'm still concerned neither is perfect
    # so long as we keep doing the weird Cardname.escape thing.
    url = "javascript:'/#{url}"
    url << "/#{escape_javascript(CGI.escape(card_id.to_s))}" if (card and card_id)
    url << "/#{attribute}" if attribute
    url << "?context='+getSlotContext(this)"
    url << "+'&' + getSlotOptions(this)"
    url << ("+'"+ args.map{|k,v| "&#{k}=#{escape_javascript(CGI.escape(v.to_s))}"}.join('') + "'") if args
    url
  end

  def header
    @template.render :partial=>'card/header', :locals=>{ :card=>card, :slot=>self }
  end

  def menu
    if card.virtual?
      return %{<span class="card-menu faint">Virtual</span>\n}
    end
    menu_options = [:view,:changes,:options,:related,:edit]
    top_option = menu_options.pop
    menu = %{<span class="card-menu">\n}
      menu << %{<span class="card-menu-left">\n}
        menu_options.each do |opt|
          menu << link_to_menu_action(opt.to_s)
        end
      menu << "</span>"
      menu << link_to_menu_action(top_option.to_s)
    menu << "</span>"
  end

  def footer
    render_partial 'card/footer'
  end

  def footer_links
    render_partial( 'card/footer_links' )   # this is ugly reusing this cache code
  end

  def option( args={}, &proc)
    args[:label] ||= args[:name]
    args[:editable]= true unless args.has_key?(:editable)
    self.options_need_save = true if args[:editable]
    concat %{<tr>
      <td class="inline label"><label for="#{args[:name]}">#{args[:label]}</label></td>
      <td class="inline field">
    }, proc.binding
    yield
    concat %{
      </td>
      <td class="help">#{args[:help]}</td>
      </tr>
    }, proc.binding
  end

  def option_header(title)
    %{<tr><td colspan="3" class="option-header"><h2>#{title}</h2></td></tr>}
  end

  def link_to_menu_action( to_action)
    menu_action = (%w{ show update }.member?(action) ? 'view' : action)
    content_tag( :li, link_to_action( to_action.capitalize, to_action, {} ),
      :class=> (menu_action==to_action ? 'current' : ''))
  end

  def link_to_action( text, to_action, remote_opts={}, html_opts={})
    link_to_remote text, {
      :url=>url_for("card/#{to_action}"),
      :update => id
    }.merge(remote_opts), html_opts
  end

  def button_to_action( text, to_action, remote_opts={}, html_opts={})
    if remote_opts.delete(:replace)
      r_opts =  { :url=>url_for("card/#{to_action}", :replace=>id ) }.merge(remote_opts)
    else
      r_opts =  { :url=>url_for("card/#{to_action}" ), :update => id }.merge(remote_opts)
    end
    button_to_remote( text, r_opts, html_opts )
  end

  def name_field(form,options={})
    form.text_field( :name, { :class=>'field card-name-field', :autocomplete=>'off'}.merge(options))
  end


  def cardtype_field(form,options={})
    @template.select_tag('card[type]', cardtype_options_for_select(Cardtype.name_for(card.type)), options)
  end

  def update_cardtype_function(options={})
    fn = ['File','Image'].include?(card.type) ?
            "Wagn.onSaveQueue['#{context}']=[];" :
            "Wagn.runQueue(Wagn.onSaveQueue['#{context}']); "
    fn << remote_function( options )
  end

  def js_content_element
    @card.hard_template ? "" : ",getSlotElement(this,'form').elements['card[content]']"
  end

  def content_field(form,options={})
    self.form = form
    @nested = options[:nested]
    pre_content =  (card and !card.new_record?) ? form.hidden_field(:current_revision_id, :class=>'current_revision_id') : ''
    editor_partial = (card.type=='Pointer' ? ((c=card.setting('input'))  ? c.gsub(/[\[\]]/,'') : 'list') : 'editor')
    User.as :wagbot do
      pre_content + clear_queues + self.render_partial( card_partial(editor_partial), options ) + setup_autosave
    end
  end                          
 
  def clear_queues
    queue_context = get_queue_context

    return '' if root.js_queue_initialized.has_key?(queue_context)
    root.js_queue_initialized[queue_context]=true

    javascript_tag(
      "Wagn.onSaveQueue['#{queue_context}']=[];\n"+
      "Wagn.onCancelQueue['#{queue_context}']=[];"
    )
  end


  def save_function
    "if(ds=Wagn.draftSavers['#{context}']){ds.stop()}; if (Wagn.runQueue(Wagn.onSaveQueue['#{context}'])) { } else {return false}"
  end

  def cancel_function
    "if(ds=Wagn.draftSavers['#{context}']){ds.stop()}; Wagn.runQueue(Wagn.onCancelQueue['#{context}']);"
  end

  def xhr?
    controller && controller.request.xhr?
  end

  def get_queue_context
    #FIXME: this looks like it won't work for arbitraritly nested forms.  1-level only
    @nested ? context.split('_')[0..-2].join('_') : context
  end

  def editor_hooks(hooks)
    # it seems as though code executed inline on ajax requests works fine
    # to initialize the editor, but when loading a full page it fails-- so
    # we run it in an onLoad queue.  the rest of this code we always run
    # inline-- at least until that causes problems.

    queue_context = get_queue_context
    code = ""
    if hooks[:setup]
      code << "Wagn.onLoadQueue.push(function(){\n" unless xhr?
      code << hooks[:setup]
      code << "});\n" unless xhr?
    end
    if hooks[:save]
      code << "Wagn.onSaveQueue['#{queue_context}'].push(function(){\n #{hooks[:save]} \n });\n"
    end
    if hooks[:cancel]
      code << "Wagn.onCancelQueue['#{queue_context}'].push(function(){\n #{hooks[:cancel]} \n });\n"
    end
    javascript_tag code
  end

  def setup_autosave
    if @nested or skip_autosave
      ""
    else
      javascript_tag "Wagn.setupAutosave('#{card.id}', '#{context}');\n"
    end
  end

  def half_captcha
    if captcha_required?
      key = card.new_record? ? "new" : card.key
      javascript_tag(%{loadScript("http://api.recaptcha.net/js/recaptcha_ajax.js")}) +
        recaptcha_tags( :ajax=>true, :display=>{:theme=>'white'}, :id=>key)
    end
  end

  def full_captcha
    if captcha_required?
      key = card.new_record? ? "new" : card.key
        recaptcha_tags( :ajax=>true, :display=>{:theme=>'white'}, :id=>key ) +
          javascript_tag(
            %{jQuery.getScript("http://api.recaptcha.net/js/recaptcha_ajax.js", function(){
              document.getElementById('dynamic_recaptcha-#{key}').innerHTML='<span class="faint">loading captcha</span>';
              Recaptcha.create('#{ENV['RECAPTCHA_PUBLIC_KEY']}', document.getElementById('dynamic_recaptcha-#{key}'),RecaptchaOptions);
            });
          })
    end
  end

  ### ------  from wagn_helper ----
  def partial_for_action( name, card=nil )
    # FIXME: this should look up the inheritance hierarchy, once we have one
    # wow this is a steaming heap of dung.
    cardtype = (card ? card.type : 'Basic').underscore
    if Rails::VERSION::MAJOR >=2 && Rails::VERSION::MINOR <=1
      finder.file_exists?("/types/#{cardtype}/_#{name}") ?
        "/types/#{cardtype}/#{name}" :
        "/types/basic/#{name}"
    elsif   Rails::VERSION::MAJOR >=2 && Rails::VERSION::MINOR > 2
      ## This test works for .rhtml files but seems to fail on .html.erb
      begin
        @template.view_paths.find_template "types/#{cardtype}/_#{name}"
        "types/#{cardtype}/#{name}"
      rescue ActionView::MissingTemplate => e
        "/types/basic/#{name}"
      end
    else
      @template.view_paths.find { |template_path| template_path.paths.include?("types/#{cardtype}/_#{name}") } ?
        "/types/#{cardtype}/#{name}" :
        "/types/basic/#{name}"
    end
  end

end

