require 'ruby-debug'
class Slot < Renderer

  cattr_accessor :render_actions
  attr_accessor  :options_need_save, :requested_view, :js_queue_initialized,
    :position, :state, :start_time, :skip_autosave, :render_args

  # This creates a separate class hash in the subclass
  class << self
    def actions() @@render_actions||={} end
    alias current_slot current
    alias current_slot= current=
  end

  def action_method(key)
    cls=self.class
    cls.actions.has_key?(key) ? cls.actions[key] : super.class.actions[key]
  end

  # FIXME: simplify this to (card, opts)
  def initialize(card, context="main_1", action="view", template=nil, opts={} )
    @card,@context,@action,@template = card,context.to_s,action.to_s,template
    Slot.current_slot ||= self

#Rails.logger.info "Slot.new #{card.name}, #{context}, #{action}, #{template}, #{opts.inspect}"
    super
    @context = "main_1" unless @context =~ /\_/
    @position = @context.split('_').last
    @subslots = []
    @state = :view
    @renders = {}
    @js_queue_initialized = {}
    
    if card and card.is_collection? and item_param=params[:item]
      @item_view = item_param if !item_param.blank?
    end
  end

### --- render action declarations --- wrapped views are defined for slots

  action(:layout) do |*a| args = a[0]||{}
Rails.logger.info "_render_layout(#{args.inspect})"
    @main_card, mc = args.delete(:main_card), args.delete(:main_content)
    @main_content = mc.blank? ? _render_core : wrap_main(mc)
  end

  action(:content) do |*a| args = a[0]||{}
    @state = 'view'
    self.requested_view = 'content'
    c = _render_naked
    c = "<span class=\"faint\">--</span>" if c.size < 10 && strip_tags(c).blank?
    wrap('content', args, wrap_content(c))
  end

  action(:new) do |*a| args = a[0]||{}
    wrap('', args, render_partial('views/new'))
  end

  action(:open) do |*a| args = a[0]||{}
    @state = :view
    self.requested_view = 'open'
    wrap('open', args, render_partial('views/open'))
  end

  action(:closed) do |*a| args = a[0]||{}
    @state = :line
    self.requested_view = 'closed'
    wrap('closed', args, render_partial('views/closed'))
  end

  action(:setting) do |*a| args = a[0]||{}
    wrap( self.requested_view = 'content', args,
          render_partial('views/setting') )
  end

  action(:edit) do |*a| args = a[0]||{}
    @state=:edit
    # FIXME CONTENT: the hard template test can go away when we phase out the old system.
    wrap('', args, card.content_template ?  _render_multi_edit() : content_field(slot.form))
  end

  action(:multi_edit) do |*a| args = a[0]||{}
    @state=:edit
    args[:add_javascript]=true
    wrap('', args, hidden_field_tag(:multi_edit, true) + _render_naked)
  end

  action(:change) do |*a| args = a[0]||{}
    self.requested_view = 'content'
    wrap('content', args, w_content = render_partial('views/change'))
  end

###---(  EDIT VIEWS )
  action(:edit_in_form) do |*a| args = a[0]||{}
    render_partial('views/edit_in_form', args.merge(:form=>form))
  end

  def subslot(card, context_base=nil, &proc)
    # Note that at this point the subslot context, and thus id, are
    # somewhat meaningless-- the subslot is only really used for tracking position.
    context_base ||= self.context
    new_position = @subslots.size + 1
    new_slot = subrenderer(card, "#{context_base}_#{new_position}")

    new_slot.state = @state
    new_slot.position = new_position

    @subslots << new_slot
    new_slot
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
      template.output_buffer ||= ''   # fixes error in CardControllerTest#test_changes
    else
      args = proc.binding
    end
    template.concat open_slot, *args
    yield(self)
    template.concat close_slot, *args
    ""
  end

  def wrap_content( content="" )
    %{<span class="#{canonicalize_view(self.requested_view)}-content content editOnDoubleClick">} +
    content.to_s +
    %{</span>} #<!--[if IE]>&nbsp;<![endif]-->}
  end

  def wrap_main(content)
    return content if p=root.params and p[:layout]=='none'
    %{<div id="main" context="main">#{content}</div>}
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
    when sob.respond_to?(:name)# &&
         #sob.name == fullname
      sob
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
#raise "process_inclusion SL (#{tcard.name}, #{options.inspect}"
Rails.logger.info "process_inclusion SL (#{tcard.name}, #{options.inspect}"
    subslot = subslot(tcard, options[:context])
    old_slot, Slot.current_slot = Slot.current_slot, subslot

    # set item_view;  search cards access this variable when rendering their content.
    subslot.item_view = options[:item] if options[:item]
    subslot.type = options[:type] if options[:type]

    # FIXME! need a different test here
    new_card = tcard.new_record? && !tcard.virtual?

    subslot.requested_view = vmode = (options[:view] || :content).to_sym
    action = case

      when [:name, :link, :linkname].member?(vmode)  ; vmode
      #when [:name, :link, :linkname].member?(vmode)  ; raise "Should be handled in chunks"
      when :edit == state
       tcard.virtual? ? :edit_auto : :edit_in_form
      when new_card
raise "Missed _main?" if tcard.name == '_main'
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

  #### --------------------  additional helpers ---------------- ###
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
    if p = root.params
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
    template.render :partial=>'card/header', :locals=>{ :card=>card, :slot=>self }
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
    template.select_tag('card[type]', cardtype_options_for_select(Cardtype.name_for(card.type)), options)
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


end

