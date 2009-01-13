require_dependency 'slot_helpers'
module WagnHelper 
  class Slot
    include SlotHelpers  
    cattr_accessor :max_char_count
    self.max_char_count = 200
    attr_reader :card, :context, :action, :renderer, :template
    attr_accessor :editor_count, :options_need_save, :state, :requested_view, :js_queue_initialized,  
      :transclusions, :position, :renderer, :form, :superslot, :char_count, :item_format, :renders, :start_time      
    attr_writer :form 
     
    def initialize(card, context="main_1", action="view", template=nil, renderer=nil )
      @card, @context, @action, @template, @renderer = card, context.to_s, action.to_s, (template||StubTemplate.new), renderer
      
      raise("context gotta include position") unless context =~ /\_/
      @position = context.split('_').last    
      @char_count = 0
      @subslots = []  
      @state = 'view'
      @renders = {}
      @renderer ||= Renderer.new(self)
    end

    def subslot(card, &proc)
      # Note that at this point the subslot context, and thus id, are
      # somewhat meaningless-- the subslot is only really used for tracking position.
      new_slot = self.class.new(card, context+"_#{@subslots.size+1}", @action, @template, @renderer)
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

    def wrap_content( content="" )
       %{<span class="content editOnDoubleClick">} + content.to_s + %{</span>}
    end    
    

           
    # FIXME: passing a block seems to only work in the templates and not from
    # internal slot calls, so I added the option passing internal content which
    # makes all the ugly block_given? ifs..                                                 
    def wrap(action="", args={}) 
      render_slot = args.key?(:is_slot) ? args.delete(:is_slot) : !request.xhr? 
      content = args.delete(:content)

      result = ""
      if render_slot
        case action.to_s
          when 'content';    css_class = 'transcluded'  
#          when 'nude'   ;   css_class = 'nude-slot'
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
        
        slot_head = '<!--[if !IE]><object><![endif]-->' +
          %{<span #{attributes.map{ |key,value| value && %{ #{key}="#{value}" }  }.join } >}
        slot_head 
        if block_given? 
          # FIXME: the proc.binding call triggers lots and lots of:
          # slot.rb:77: warning: tried to create Proc object without a block 
          # which makes the test output unreadable.  should do a real fix instead of hiding the issue 
          warn_level, $VERBOSE = $VERBOSE, nil;
          @template.concat(slot_head, proc.binding) 
          $VERBOSE = warn_level
        else
          result << slot_head
        end
      end      
      if block_given?
        yield(self)
      else
        result << content
      end
      if render_slot
        if block_given?
          warn_level, $VERBOSE = $VERBOSE, nil;
          @template.concat("</span></object>" , proc.binding)
          $VERBOSE = warn_level
        else
          result << "</span></object>"
        end
      end    
      result
    end
    
    def cache_action(cc_method) 
      (if CachedCard===card 
        card.send(cc_method) || begin
          cached_card, @card = card, Card.find_by_key_and_trash(card.key, false) || raise("Oops! found cached card for #{card.key} but couln't find the real one") 
          content = yield(@card)
          cached_card.send("#{cc_method}=", content.clone)  
          content
        end
      else
        yield(card)
      end).clone
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

    def render(action, args={})      
      #warn "<render(#{card.name}, #{@state}).render(#{action}, item=>#{args[:item]})"
      
      rkey = self.card.name + ":" + action.to_s
      root.renders[rkey] ||= 1; root.renders[rkey] += 1
      #root.start_time ||= Time.now.to_f

      ok_action = case
        when root.renders[rkey] > System.max_renders                    ; :too_many_renders
        #when (Time.now.to_f - root.start_time) > System.max_render_time ; :too_slow
        when denial = deny_render?(action)                              ; denial
        else                                                            ; action
      end

      w_content = nil
      result = case ok_action

      ###-----------( FULL )
        when :open, :view, :card
          @state = :view; self.requested_view = 'card'
          # FIXME: accessing params here is ugly-- breaks tests.
          #w_action = (@template.params[:view]=='content' && context=="main_1") ? 'nude' : 'open'
          w_action = 'open'
          w_content = render_partial('card/view')

        when :closed, :line    
          @state = :line; w_action='closed'; self.requested_view = 'line'
          w_content = render_partial('card/line')  # --> slot.wrap_content slot.render( :expanded_line_content )   
          
      ###----------------( NAME)
      
        when :link;   link_to_page card.name, card.name, :class=>"cardname-link #{card.new_record? ? 'wanted-card' : 'known-card'}"
        when :name;   card.name
        when :linkname;  Cardname.escape(card.name)
        when :change;
          w_action = self.requested_view = 'content'
          w_content = render_partial('card/change')

      ###---(  CONTENT VARIATIONS ) 
        #-----( with transclusions processed )
        when :content;  
          w_action = self.requested_view = 'content'  
          c = self.render( :expanded_view_content)
          w_content = wrap_content(((c.size < 10 && strip_tags(c).blank?) ? "<span class=\"faint\">--</span>" : c))

        when :expanded_view_content, :raw 
          @state = 'view'
          expand_transclusions(  cache_action('view_content') {  card.post_render( render(:open_content)) } )

        when :expanded_line_content
          expand_transclusions(  cache_action('line_content') { render(:closed_content) } )


        #-----( without transclusions processed )

        when :closed_content;   render_card_partial(:line)   # in basic case: --> truncate( slot.render( :open_content ))
        when :open_content;     render_card_partial(:content)  # FIXME?: 'content' is inconsistent
        when :raw_content;    
          #warn "rendering #{card.name} refs=#{card.references_expired} card.content=#{card.content}"
          @renderer.render( card, args.delete(:content) || "", update_refs=card.references_expired)
          
      ###---(  EDIT VIEWS ) 

        when :edit;  @state=:edit;  card.hard_template ? render(:multi_edit) : content_field(slot.form)
          
        when :multi_edit;
          @state=:edit 
          args[:add_javascript]=true
          hidden_field_tag( :multi_edit, true) +
          expand_transclusions( render(:raw_content) )

        when :edit_in_form
          render_partial('card/edit_in_form', args.merge(:form=>form))
            
        ###---(  EXCEPTIONS ) 
        
          when :deny_view, :edit_auto, :too_slow, :too_many_renders, :open_missing, :closed_missing
            render_partial("card/#{ok_action}", args)

  
        else raise("Unknown slot render action '#{ok_action}'")
      end
      if w_content
        args[:is_slot] = true unless args.key?(:is_slot)
        result = wrap(w_action, { :content=>w_content }.merge(args))
      end
      
#      result ||= "" #FIMXE: wtf?
      result << javascript_tag("setupLinksAndDoubleClicks()") if args[:add_javascript]
      result
    rescue Card::PermissionDenied=>e
      return "Permission error: #{e.message}"
      
    end

    def expand_transclusions(content) 
      #return ("skip(#{card.name}):"+content) 
      if card.name.template_name?          
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
            fullname = tname+'' #weird.  have to do this or the tname gets busted in the options hash!!
            #warn "options for #{tname}: #{options.inspect}"
            fullname.to_absolute(options[:base]=='parent' ? card.name.parent_name : card.name)
            fullname.gsub!('_user', User.current_user.card.name)
            #logger.info("absolutized tname and now have these transclusion options: #{options.inspect}")

            if fullname.blank?  
               # process_transclusion blows up if name is nil
              "{<bogus/>{#{fullname}}}" 
            else
    #          options[:view]='edit' if @state == :edit

              tcard = case
                when @state==:edit
                  ( Card.find_by_name( fullname ) || 
                    Card.find_phantom( fullname ) || 
                    Card.new( :name=>  fullname ) )
                else
                  CachedCard.get fullname
                end
          
              #warn("sending these options for processing: #{options.inspect}")
         
              tcontent = process_transclusion( tcard, options ) 
              self.char_count += (tcontent ? tcontent.length : 0)
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
      StubTemplate===@template ? render_stub(partial, locals) : @template.render(:partial=>partial, :locals=>locals)
    end

    def card_partial(action) 
      # FIXME: I like this method name better- maybe other calls should resolve here instead
      @template.partial_for_action(action, card)
    end
    
    def render_card_partial(action, locals={})
       render_partial card_partial(action), locals
    end
    
    def process_transclusion( card, options={} )  
      #warn("<process_transclusion card=#{card.name} options=#{options.inspect}")
      subslot = subslot(card)  
      old_slot, @template.controller.slot = @template.controller.slot, subslot

      # set item_format;  search cards access this variable when rendering their content.
      subslot.item_format = options[:item] if options[:item]                             
      
      # FIXME! need a different test here   
      new_card = card.new_record? && !card.phantom?
      
      state, vmode = @state.to_sym, (options[:view] || :content).to_sym      
      subslot.requested_view = vmode
      action = case
        when [:name, :link].member?(vmode)  ; vmode
        when state==:edit                   ; card.phantom? ? :edit_auto : :edit_in_form   
        when new_card                       ; state==:line  ? :closed_missing : :open_missing
        when state==:line                   ; :expanded_line_content
        else                                ; vmode
      end
=begin      
       # these take precedence over state=view/line
        else
          case state
          when :edit   ; card.phantom? ? :edit_auto : :edit_in_form                           
          when :line   ; :expanded_line_content           
          # now we are in state==:view, switch on viewmode (from transclusion syntax)
          else         ; vmode
          end
        end
=end
      #logger.info("<transclusion_case: state=#{state} vmode=#{vmode} --> Action=#{action}, Option=#{options.inspect}")

      result = subslot.render action, options
      @template.controller.slot = old_slot
      result
    end   
    
    def method_missing(method_id, *args, &proc) 
      @template.send(method_id, *args, &proc)
    end

    
    def render_stub(partial, locals={})
      raise("Invalid partial") if partial.blank? 
      case partial
        when "card/view"
          %{\n<div class="view">\n} + wrap_content( render( :expanded_view_content ))+ %{\n</div>\n}
        when "card/line"
          %{\n<div class="view">\n} + wrap_content( render(:expanded_line_content) ) + %{\n</div>\n}
        when "basic/content"
          render :raw_content
        when "basic/line"
          truncatewords_with_closing_tags( render( :custom_view ))
        else
          "No Stub for #{partial}"
      end
    end
  end   
  
  
  # For testing/console use of a slot w/o controllers etc.
  class StubTemplate
    attr_accessor :indent, :slot
    # for testing & commandline use  
    # not totally happy with this..    
     
    def params
      return {}
    end
    
    def controller
      @controller ||= (Struct.new(:slot)).new(nil)
    end 
    
    def partial_for_action(action, card) 
      "#{card.type.to_s.downcase}/#{action}"
    end  
    
  end
  
end