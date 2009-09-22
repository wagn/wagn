require "ruby-debug"
require_dependency 'slot_helpers'

class Slot
  include SlotHelpers
  cattr_accessor :max_char_count
  self.max_char_count = 200
  attr_reader :card, :context, :action, :renderer, :template
  attr_accessor :editor_count, :options_need_save, :state,
    :requested_view, :js_queue_initialized, :transclusions,
    :position, :renderer, :form, :superslot, :char_count,
    :item_format, :type, :renders, :start_time,
    :transclusion_view_overrides, :skip_autosave
  attr_writer :form

  VIEW_ALIASES = {
    :view => :open,
    :card => :open,
    :line => :closed,
  }

  def initialize(card, context="main_1", action="view", template=nil, opts={}, renderer=nil)
    @card, @context, @action, @renderer =
        card, context.to_s, action.to_s, renderer
#ActionController::Base.logger.info("requested_view:#{requested_view} :xml_view #{card.name}\n") if opts[:format] == :xml
    @requested_view = :xml_view if  opts[:format] == :xml
    context = "main_1" unless context =~ /\_/
    @template = template || (xml? && card.xml_template) ||
       StubTemplate.new(card, context, action, opts)
    @position = context.split('_').last
    @char_count = 0
    @subslots = []
    @state = 'view'
    @renders = {}
    @transclusion_view_overrides = opts[:transclusion_view_overrides]
    unless @renderer
      @renderer = Renderer.new
      @renderer.render_xml = xml?
    end
  end

  def xml?
    [:xml_view, :xml_content].member?(@requested_view)
  end
 
  def subslot(card, &proc)
    # Note that at this point the subslot context, and thus id, are
    # somewhat meaningless-- the subslot is only really used for tracking position.
ActionController::Base.logger.info("INFO:subslot(#{card.name}, #{@requested_view}::#{action}, #{@template.class}, #{@renderer.class})\n")
    new_slot = self.class.new(card, context+"_#{@subslots.size+1}", @action, @template, {}, @renderer)
    new_slot.requested_view = @requested_view
    new_slot.state = @state
    @subslots << new_slot
    new_slot.superslot = self
    new_slot.position = @subslots.size
    new_slot
  end

  def root
    superslot ? superslot.root : self
  end

  def form
    @form ||= begin
      # NOTE this code is largely copied out of rails fields_for
      options = {} # do I need any? #args.last.is_a?(Hash) ? args.pop : {}
      block = Proc.new {}
      builder = options[:builder] || ActionView::Base.default_form_builder
      card.name.gsub!(/^#{root.card.name}\+/, '+') if root.card.new_record?  ##FIXME -- need to match other relative inclusions.
      fields_for = builder.new("cards[#{card.name.pre_cgi}]", card, @template, options, block)
    end
  end    
  
  def full_field_name(field)   
    form.text_field(field).match(/name=\"([^\"]*)\"/)[1] 
  end

  def wrap_content( content="" )
    %{<span class="#{canonicalize_view(self.requested_view)}-content content editOnDoubleClick">} +
       content.to_s +
    %{</span><!--[if IE]>&nbsp;<![endif]-->}
  end

  def js
    @js ||= SlotJavascript.new(self)
  end

  # FIXME: passing a block seems to only work in the templates and not from
  # internal slot calls, so I added the option passing internal content which
  # makes all the ugly block_given? ifs..
  def wrap(action="", args={})
    render_slot = args.key?(:add_slot) ? args.delete(:add_slot) : !request.xhr?
    content = args.delete(:content)

    open_slot, close_slot = "",""

    result = ""
    if render_slot
      case action.to_s
        when 'content';    css_class = 'transcluded'
        when 'exception';  css_class = 'exception'
         when 'nude'   ;   css_class = 'nude-slot'
        else begin
          css_class = 'card-slot '
          css_class << (action=='closed' ? 'line' : 'paragraph')
          css_class << ' full' if (context=~/main/ or (action!='view' and action!='closed'))
          css_class << ' sidebar' if context=~/sidebar/
        end
      end

      css_class << " wrapper cardid-#{card.id} type-#{card.type}" if card

      attributes = {
        :cardId   => (card && card.id),
        :style    => args[:style],
        :view     => args[:view],
        :item     => args[:item],
        :base     => args[:base], # deprecated
        :class    => css_class,
        :position => position
      }

      slot_attr = attributes.map{ |key,value| value && %{ #{key}="#{value}" }  }.join
      open_slot = "<div #{slot_attr}>"
      close_slot= "</div>"
    end

    if block_given?
      if (Rails::VERSION::MAJOR >=2 && Rails::VERSION::MINOR >= 2)
        args = nil
        @template.output_buffer ||= ''   # fixes error in CardControllerTest#test_changes
      else
        args = proc.binding
      end
      @template.concat open_slot, *args
      yield(self)
      @template.concat close_slot, *args
      return ""
    else
      return open_slot + content + close_slot
    end
  end

  # Store block output in cc_method attribute in the cache
  def cache_action(cc_method)
    cc = card
    get_value = if cc && CachedCard===cc
      cc.send(cc_method) || begin
        if @card = Card.find_by_key_and_trash(cc.key, false)
# || raise("Oops! found cached card for #{cc.key} but couldn't find the real one Method(#{cc_method})")
          content = yield(cc)
          cc.send("#{cc_method}=", content.clone)
          content
        else
          msg="Oops! found cached card for #{cc.key} but couldn't find the real one Method(#{cc_method})"
          raise msg
        end
      end
    elsif cc
      yield(cc)
    else
      msg="Oops! found cached card for #{card.key} but couldn't find the real one Method(#{cc_method})"
      raise msg
    end
raise "Error: Nil for #{cc_method} Card:#{card.name}" if get_value == nil
    get_value.clone
  end
  
  def deny_render?(action)
    case
      when [:deny_view, :edit_auto, :open_missing, :closed_missing].member?(action);
        false
      when card.new_record?
        false # need create check...
      when [:edit, :edit_in_form, :multi_edit].member?(action)
        !card.ok?(:edit) and :deny_view #should be deny_edit
      else
        !card.ok?(:read) and :deny_view
    end
  end

  def canonicalize_view( view )
    view = view.to_sym
    VIEW_ALIASES[view.to_sym] || view
  end

  def Slot.ok_xml_action?(action)
    [:xml_missing, :xml, :xml_content, :xml_expanded, :naked].member?(action)
  end

  def Slot.ok_action?(action)
    [:naked_content, :naked].member?(action) || ! Slot.ok_xml_action?(action)
  end

  def ok_action(action)
#raise "Action?(#{action})" if xml? && ! Slot.ok_xml_action?(action)
#raise "Action?(#{action})" if !xml? && ! Slot.ok_action?(action)
    rkey = self.card.name + ":" + action.to_s
    root.renders[rkey] ||= 1 
    root.renders[rkey] += 1 unless [:name, :link].member?(action)
    #root.start_time ||= Time.now.to_f
#ActionController::Base.logger.info("OkAction(#{rkey})#{root.renders[rkey]}\n")

    case
      when root.renders[rkey] > System.max_renders                    ;
#raise "Infinite loop #{action} #{@requested_view}" if root.renders[rkey] > System.max_renders
        :too_many_renders
      #when (Time.now.to_f - root.start_time) > System.max_render_time ; :too_slow
      when denial = deny_render?(action)                              ; denial
      else                                                            ; action
    end
  end

  def render(action, args={})
    @requested_view = :xml_view if action == :xml
#ActionController::Base.logger.info("requested_view:#{requested_view} :xml action #{card.name}\n") if action == :xml
    w_content = nil
    result = case ok_action = ok_action(action)
    ###-----------( FULL )
      when :xml_content, :xml, :xml_expanded
        render_xml(ok_action, args)

      when :new
        w_content = render_partial('views/new')
        
      when :open, :view, :card
        @state = :view; self.requested_view = 'open'
        # FIXME: accessing params here is ugly-- breaks tests.
        #w_action = (@template.params[:view]=='content' && context=="main_1") ? 'nude' : 'open'
        w_action = 'open'
        w_content = render_partial('views/open')

      when :closed, :line
        @state = :line; w_action='closed'; self.requested_view = 'closed'
        w_content = render_partial('views/closed')  # --> slot.wrap_content slot.render( :expanded_line_content )   
        
    ###----------------( NAME)

      #when :link;   link_to_page card.name, card.name, :class=>"cardname-link #{card.new_record? ? 'wanted-card' : 'known-card'}"
      when :link;
        opts = {:class=>"cardname-link #{(card.new_record? && !card.phantom?) ? 'wanted-card' : 'known-card'}"}
        opts[:type] = slot.type if slot.type
        link_to_page card.name, card.name, opts
      when :name;   card.name
      when :linkname;  Cardname.escape(card.name)
      when :titled;
        content_tag( :h1, less_fancy_title(card.name) ) + self.render( :content )

      when :rss_titled;
        # content includes wrap  (<object>, etc.) , which breaks at least safari rss reader.
        content_tag( :h2, less_fancy_title(card.name) ) + self.render( :expanded_view_content )

      when :rss_change;
        w_action = self.requested_view = 'content'
        render_partial('views/change')
        
      when :change;
        w_action = self.requested_view = 'content'
        w_content = render_partial('views/change')

    ###---(  CONTENT VARIATIONS )
      #-----( with transclusions processed )
      when :content;
        w_action = self.requested_view = 'content'
        c = self.render( :expanded_view_content)
        w_content = wrap_content(((c.size < 10 && strip_tags(c).blank?) ? "<span class=\"faint\">--</span>" : c))

      when :expanded_view_content, :naked, :raw # raw is DEPRECATED
        @state = 'view'
        expand_transclusions(  cache_action('view_content') { |c|
          c.post_render( render(:open_content) )
        } )

      when :expanded_line_content
        expand_transclusions(  cache_action('line_content') { |c| render(:closed_content) } )

      #-----( without transclusions processed )
      when :closed_content;   render_card_partial(:line)   # in basic case: --> truncate( slot.render( :open_content ))
      when :open_content;     render_card_partial(:content)  # FIXME?: 'content' is inconsistent
      when :naked_content, :raw_content # raw_content is DEPRECATED
        #warn "rendering #{card.name} refs=#{card.references_expired} card.content=#{card.content}"
#debugger if xml? ^ @renderer.render_xml
        @renderer.render( card, args.delete(:content) || "", card.references_expired)

    ###---(  EDIT VIEWS )

      when :edit;  @state=:edit;  card.hard_template ? render(:multi_edit) : content_field(slot.form)

      when :multi_edit;
        @state=:edit
        args[:add_javascript]=true
        hidden_field_tag( :multi_edit, true) +
        expand_transclusions( render(:naked_content) )

      when :edit_in_form
        render_partial('views/edit_in_form', args.merge(:form=>form))
            
      ###---(  EXCEPTIONS ) 
        
      when :deny_view, :edit_auto, :too_slow, :open_missing, :closed_missing, :too_many_renders;
          render_partial("views/#{ok_action}", args)
      else
raise "unknown card view #{ok_action}"
        "<strong>#{card.name} - unknown card view: '#{ok_action}'</strong>"
    end
    if w_content
      args[:add_slot] = true unless args.key?(:add_slot)
      result = wrap(w_action, { :content=>w_content }.merge(args))
    end

#    result ||= "" #FIMXE: wtf?
    result << javascript_tag("setupLinksAndDoubleClicks();") if args[:add_javascript]
    result
  rescue Card::PermissionDenied=>e
    return "Permission error: #{e.message}"
  end

  def expand_transclusions(content, args={})
    #return ("skip(#{card.name}):"+content)
    if card && card.name.template_name?
      # KLUGILICIOIUS: if we leave the {{}} transclusions intact they may get processed by
      #  an outer card expansion-- causing weird rendering oddities.  the bogus thing
      #  seems to work ok for now.
      return content.gsub(/\{\{/,'{<bogus />{').gsub(/\}\}/,'}<bogus />}')
    end
    #content = "noskip(#{card.name}):" + content
    content.gsub!(Chunk::Transclude::TRANSCLUDE_PATTERN) do
      if @state==:line && self.char_count > Slot.max_char_count
        ""
      else
        begin
          match = $~
          tname, options = Chunk::Transclude.parse(match)
          if view_map = root.transclusion_view_overrides
            if translated_view = view_map[ canonicalize_view( options[:view] )]
              options[:view] = translated_view
            end
          end
          fullname = tname+'' #weird.  have to do this or the tname gets busted in the options hash!!
          #warn "options for #{tname}: #{options.inspect}"
          fullname.to_absolute(options[:base]=='parent' ? card.name.parent_name : card.name)
          fullname.gsub!('_user', User.current_user.card.name)
          options[:fullname] = fullname
          options[:showname] = tname.to_show(fullname)
          #logger.info("absolutized tname and now have these transclusion options: #{options.inspect}\n")

          if fullname.blank?
             # process_transclusion blows up if name is nil
            "{<bogus/>{#{fullname}}}" 
          else                                             
            params = @template.controller.params
            specified_content = params && params[tname.gsub(/\+/,'_')] || ''
 
            tcard = case
              when @state==:edit
                ( Card.find_by_name( fullname ) || 
                  Card.find_phantom( fullname ) || 
                  Card.new(   :name=>fullname, :type=>options[:type], :content=>specified_content ) )
              else
                CachedCard.get fullname
            end

            #warn("sending these options for processing: #{options.inspect}")

#raise "Transclude error" if tcard.nil?
            tcontent = unless tcard.nil? && !tcard
              process_transclusion( tcard, options )
            else 
              "Transclude error: #{card.name}"
            end
            self.char_count += (tcontent ? tcontent.length : 0)
                                    
            # FIXME: Isn't this totally the wrong place for this?
            if size = options[:size] 
              size = (size.to_s == "full" ? "" : "_#{size}")
              tcontent = tcontent.gsub(/_medium(\.\w+\")/,"#{size}"+'\1')
            end
              
            tcontent
              
          end
        rescue Card::PermissionDenied
          ""
        end
      end
    end
    content
  end

  def render_partial( partial, locals={} )
    locals =  { :card=>card, :slot=>self }.merge(locals)
ActionController::Base.logger.info("INFO:render_partial(#{partial}, #{@template.class}, #{locals[:card].name} #{card.name}\n")

    res = if StubTemplate===@template
      render_stub(partial, locals)
    else
      @template.render(:partial=>partial, :locals=>locals)
    end
    res || "Nothing #{partial} #{@template.class}"
  end

  def card_partial(action)
    # FIXME: I like this method name better- maybe other calls should resolve here instead
    @template.partial_for_action(action, card)
  end

  def render_card_partial(action, locals={})
     render_partial card_partial(action), locals
  end

  def render_xml(action, args={})

    result = case ok_action = ok_action(action)
      when :xml_missing ; "<no_card>#{card.name}</no_card>"
      when :name ; card.name
      when :xml_content
        @renderer.render_xml = true if xml?
        render_card_partial(ok_action, args)  # FIXME?: 'content' is inconsistent
      when :naked
@renderer.render_xml = true if xml?
ActionController::Base.logger.info("INFO:Need renderer xml?\n") if xml? ^ @renderer.render_xml
        @renderer.render( card, args.delete(:content)||card.content||"", card.references_expired )
      when :xml, :xml_expanded
        @state = 'view'
        expand_transclusions_xml( cache_action('xml_content') { render_xml(:xml_content) } )

      ###---(  EXCEPTIONS )
      when :deny_view, :edit_auto, :too_slow, :open_missing, :closed_missing, :too_many_renders
          "Error Path: "+render_partial("card/#{ok_action}", args)
      else raise("Unknown slot render action '#{ok_action}'")
    end
if result.nil?
#ActionController::Base.logger.info("RR:Nothing #{ok_action} #{card.name} #{@template.class}\n")
result="Nil Result"
end
    result
  end

  def expand_transclusions_xml(content, options={})
    if card.name.template_name?
      # KLUGILICIOIUS: if we leave the {{}} transclusions intact they may
      # get processed by an outer card expansion-- causing weird rendering
      # oddities.  The bogus thing seems to work ok for now.
      return content.gsub(/\{\{/,'{<bogus />{').gsub(/\}\}/,'}<bogus />}')
    end
    content.gsub!(Chunk::Transclude::TRANSCLUDE_PATTERN) do
      begin
        match = $~
        match_str = match[1]+(match[3]||'')
        tname, options = Chunk::Transclude.parse(match)
        if view_map = root.transclusion_view_overrides
          if translated_view = view_map[ canonicalize_view( options[:view] )]
            options[:view] = translated_view
          end
        end
        fullname = tname+''
        fullname.to_absolute(options[:base]=='parent' ? card.name.parent_name : card.name)
        fullname.gsub!('_user', User.current_user.card.name)

        if fullname.blank? # process_transclusion blows up if name is nil
          "{<bogus/>{#{fullname}}}"
        else
          options[:match_str] = match_str
          options[:view] ||= :xml_content
          if (tcard = CachedCard.get fullname) && !tcard.nil?
            process_transclusion(tcard, options)
          else 
            "Transclude error: #{card.name}"
          end
        end
      rescue Card::PermissionDenied
        "Perm?"
      end
    end
    content
  end

#   General

  def process_transclusion( card, options={} )
    #warn("<process_transclusion card=#{card.name} options=#{options.inspect}")
    match_str = options[:match_str]
    subslot = subslot(card)
    #subslot.controller = @controller
    controller = @template.controller
    #controller = @controller
    old_slot, controller.slot = controller.slot, subslot

    # set item_format;  search cards access this variable when rendering their content.
    subslot.item_format = options[:item] if options[:item]
    subslot.type = options[:type] if options[:type]

    # FIXME! need a different test here
    new_card = card.new_record? && !card.phantom?
raise "Subslot missmatch; #{subslot.requested_view}, #{requested_view}" if subslot.requested_view != @requested_view
    state, vmode = @state.to_sym, xml? ? :xml_content : (options[:view] || :open_content).to_s
    vmode = vmode.to_sym
#ActionController::Base.logger.info("requested_view sub:#{subslot.requested_view} xml:#{xml?}:#{subslot.xml?} #{card.name} vmode:#{vmode} #{card.name}\n")
    subslot.requested_view = vmode
    @renderer.render_xml = true if xml?
#debugger if xml? ^ @renderer.render_xml
    action = case
      when [:name, :link].member?(vmode)  ; vmode
      when state==:edit                   ; card.phantom? ? :edit_auto : :edit_in_form
      when new_card; [:xml, :xml_content].member?(vmode) ? :xml_missing : state==:line ? :closed_missing : :open_missing
      when state==:line                   ; :expanded_line_content
      when [:xml, :xml_content].member?(vmode) ; vmode
      else                                ; vmode
    end
ActionController::Base.logger.info("<transclusion_case: state=#{state} vmode=#{vmode} --> Action=#{action}, Option=#{options.inspect}\n")

    result = if xml?
      xmltag = subslot.card.name.tag_name
      match_str ||= '' 
ActionController::Base.logger.info("Convert nil card #{card.name}\n") if card && card.nil?
      #card = nil if card && card.nil?
      if !card.nil? || card
        sub_render = subslot.render_xml(action, options)
sub_render = "NilClass" if sub_render.nil?
       %{\n<card name="#{xmltag}" type="#{subslot.card.type}" transclude="#{match_str}">} +
        sub_render + %{</card>}
      else
"Nil Card ... #{action}"
      end
    else
      subslot.render(action, options)
    end
    @template.controller.slot = old_slot
    result
  end

  def method_missing(method_id, *args, &proc)
    # silence Rails 2.2.2 warning about binding argument to concat.  tried detecting rails 2.2
    # and removing the argument but it broken lots of integration tests.
    ActiveSupport::Deprecation.silence { @template.send(method_id, *args, &proc) }
  end

  def render_stub(partial, locals={})
    raise("Invalid partial") if partial.blank?
ActionController::Base.logger.info("INFO:render_stub(#{partial},#{card.name})\n")
    case partial
      when "basic/content"
        locals[:format] = :xml if xml?
        @renderer.render( card, locals.delete(:content) || "", card.references_expired)
        #@template.render_partial(partial, locals)
        #%{\n<div class="view">\n} + wrap_content( @renderer.render(card) ) + %{\n</div>\n}
      when "basic/xml_content"
        @renderer.render( card, locals.delete(:content) || "", card.references_expired)
        #@template.render_partial(partial,locals)
      when "views/open_missing";
        #@renderer.render_xml = true if xml?
        #@template.render(:partial=>partial)
        %{\n<div class="view">\n} + wrap_content( "Add #{card.name}" ) + %{\n</div>\n}
      when "views/too_many_renders";
        %{Oops There must be a transclude loop including #{card.name} => #{card.content}}
      else
        "No Stub for #{partial} Name:#{card.name}"
    end
  end

  def self.full_sanitizer
    @full_sanitizer ||= HTML::FullSanitizer.new
  end
end

# For testing/console use of a slot w/o controllers etc.
class StubTemplate < ActionView::Template
  attr_accessor :indent, :slot, :card, :as_xml, :controller

  def initialize(card, context="nocontext", action="view", opts={}, controller=nil)
    @controller = controller || CardController.new()
    super('app/views')
    @card = card
    @as_xml = opts[:format] == :xml
  end

  def render_partial(partial, locals)
    inline = %{ get_slot.render(:partial => "#{partial}") }
xml= locals[:slot].xml?
raise "StubRender:#{xml} C:#{locals[:card].name} P:#{partial}"
    render([:inline=>inline], locals)
  end

  def partial_for_action(action, card)
    ty = card ? card.type : "NoCard"
    "#{ty.to_s.downcase}/#{action}"
  end
end
