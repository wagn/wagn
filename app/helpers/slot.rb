require_dependency 'slot_helpers'
module WagnHelper 
  class Slot
    include SlotHelpers  
    
    cattr_accessor :max_char_count
    self.max_char_count = 200
    attr_reader :card, :context, :action, :renderer, :template
    attr_accessor :editor_count, :options_need_save, :state, :requested_view,
      :transclusions, :position, :renderer, :form, :superslot, :char_count     
    attr_writer :form 
     
    def initialize(card, context="main_1", action="view", template=nil, renderer=nil )
      @card, @context, @action, @template, @renderer = card, context.to_s, action.to_s, (template||StubTemplate.new), renderer
      
      raise("context gotta include position") unless context =~ /\_/
      @position = context.split('_').last    
      @char_count = 0
      @subslots = []  
      @state = 'view'
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

    def form
      @form ||= begin
        # NOTE this code is largely copied out of rails fields_for
        options = {} # do I need any? #args.last.is_a?(Hash) ? args.pop : {}
        block = Proc.new {}
        builder = options[:builder] || ActionView::Base.default_form_builder
        fields_for = builder.new("cards[#{card.id}]", card, @template, options, block)       
      end
    end

    def wrap_content( content="" )
       %{<span class="content editOnDoubleClick">} + content.to_s + %{</span>}
    end    
           
    # FIXME: passing a block seems to only work in the templates and not from
    # internal slot calls, so I added the option passing internal content which
    # makes all the ugly block_given? ifs..                                                 
    def wrap(action="", render_slot=nil, content="") 
      render_slot = render_slot.nil? ? !request.xhr? : render_slot 
      result = ""
      if render_slot
        case action
          when 'content';    css_class = 'transcluded'  
          when 'nude';   css_class = 'nude-slot'
          else begin
            css_class = 'card-slot '      
            if action=='line'  
              css_class << 'line' 
            else
              css_class << 'paragraph'                     
            end
            css_class << ' full' if (context=~/main/ or (action!='view' and action!='line'))
            css_class << ' sidebar' if context=~/sidebar/
          end
        end       
        
        css_class << " cardid-#{card.id}" if card
        
        id_attr = card ? %{cardId="#{card.id}"} : ''
        slot_head = %{<span #{id_attr} class="#{css_class}" position="#{position}" >}
        if block_given?
          @template.concat(slot_head, proc.binding) 
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
          @template.concat("</span>" , proc.binding)
        else
          result << "</span>"
        end
      end    
      result
    end
    
    def cache_action(cc_method) 
      if CachedCard===card 
        card.send(cc_method) || begin
          cached_card, @card = card, Card.find_by_key_and_trash(card.key, false) || raise("Oops! found cached card for #{card.key} but couln't find the real one") 
          content = yield(@card)
          cached_card.send("#{cc_method}=", content)  
          content
        end
      else
        yield(card)
      end
    end

    def render(action, args={})      
      #logger.info("<render(#{card.name}, #{@state}).render(#{action})")
      if action==:denied
        # pass
      elsif card.new_record? 
        # FIXME-- check if create.ok?
      elsif !card.ok?(:read) 
        return render(:denied)
      end
      wrap = args.has_key?(:wrap) ? args[:wrap] : true  # default for these is wrap
      card_and_slot = { :card=>self.card, :slot=>self }
      result = case action
        when :open, :view;  
          @state = :view; self.requested_view = 'card'
          # FIXME: accessing params here is ugly-- breaks tests.
          @action = (@template.params[:view]=='content' && context=="main_1") ? 'nude' : 'view'
          wrap(@action, wrap, self.render_partial( 'card/view') )  # --> slot.wrap_content slot.render( :expanded_view_content ) 

        when :closed, :line;     
          @state = :line; self.requested_view = 'line'
          wrap('line', wrap, self.render_partial( 'card/line') )  # --> slot.wrap_content slot.render( :expanded_line_content )   

        when :edit;     
          @state = :edit; expand_transclusions( self.render( :raw_content ))
          
        when :content;  
          self.requested_view = 'content'  
          c = self.render( :expanded_view_content )
          wrap('content',wrap, wrap_content(((c.size < 10 && strip_tags(c).blank?) ? "<span class=\"faint\">--</span>" : c)))

        when :link;   
          link_to_page card.name, card.name, :class=>"cardname-link"
        
        when :name;
          card.name
          
        when :raw;    
          self.render( :expanded_view_content )  
          
        when :expanded_view_content
          expand_transclusions(  cache_action('view_content') {  card.post_render( render(:custom_view_content)) } )

        when :expanded_line_content
          expand_transclusions( cache_action('line_content') { render(:custom_line_content) } )

        when :custom_line_content;  
          render_partial(custom_partial_for(:line))   # in basic case: --> truncate( slot.render( :custom_view_content ))
        when :custom_view_content;  
          render_partial(custom_partial_for(:content))  # FIXME?: 'content' is inconsistent
        when :edit_connection; 
          # FIMXE:  what's going on here?
        
        when :denied;
          %{<span class="denied">Sorry #{::User.current_user.card.name}, you need permissions to view #{card.name}</span>}
          
        when :auto_card_notice
          %{<div class="faint"><em>#{args[:requested_name] || card.name} is an Auto card</em><div>} 
          
        when :create_transclusion
            %{<div class="faint createOnClick" view="#{args[:view]}" position="#{position}" cardid="" cardname="#{card.name}">}+
            %{Add #{args[:requested_name] || card.name}</div>}
            # + ((args[:view]=='edit' || parent.card.type == 'Pointer') ? "<br/>" : "")

        when :missing_transclusion
          %{<span class="faint" position="#{position}" cardid="" cardname="#{card.name}">}+
            %{#{args[:requested_name] || card.name}</span>}

        when :edit_transclusion
          ((inst = card.edit_instructions) ?
            @template.render( :partial=> 'instructions', :locals=>{ :instructions=> inst } ) : '' ) +           
          %{<div class="edit-area">} +
              %{<span class="title">} +
                link_to_page(@template.less_fancy_title(card), card.name) + 
              "</span>" +
              content_field( form, :nested=>true ) +
            "</div>"
        when :raw_content; 
          @renderer.render( card, args.delete(:content) || "", update_refs=false)

        else raise("Unknown slot render action '#{action}'")
      end   
      result ||= "" #FIMXE: wtf?
      result << javascript_tag("setupLinksAndDoubleClicks()") if args[:add_javascript]
      #warn "FINISH: #{action} card=#{card.name} result = #{result}" 
      #ActiveRecord::Base.logger.info("slot(#{card.name}, #{@state}).render(#{action}, #{args})  ---> #{result.gsub(/\n/," ")}")
      result
    end

    def expand_transclusions(content) 
      #logger.info("<expand_transclusions content=#{content}>")
      #content="#{card.name}=~/*template/" + content
      #return ("skip(#{card.name}):"+content) 
      if card.name =~ /\*template/           
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
          match = $~
          #warn "MATCH: #{match.inspect} #{match.to_a}"
          text = match[0]
          requested_name = match[1].strip
          requested_name.gsub!(/_self/, card.name)
          relative = match[2]
          options = {
            :requested_name=>requested_name,
            :view  => 'content',
            :base  => 'self',
          }.merge(Hash.new_from_semicolon_attr_list(match[4]))  
          options[:view]='edit' if @state == :edit
              
          # compute transcluded card name
          transcluded_card_name = relative ? 
             (options[:base]=='parent' ? card.name.parent_name : card.name) + requested_name :
             requested_name

          card = case
            when @state==:edit
              (Card.find_by_name(transcluded_card_name) || 
                Card.find_phantom(transcluded_card_name) ||
                 Card.new(:name=>transcluded_card_name))
            else
              CachedCard.get(transcluded_card_name)
          end
         
          transcluded_content = process_transclusion( card, options ) 
          self.char_count += (transcluded_content ? transcluded_content.length : 0)
          transcluded_content
        end
      end  
      content 
    end
       
    def render_partial( partial, locals={} ) 
      if StubTemplate===@template
        render_stub(partial, { :card=>card, :slot=>self }.merge(locals) )
      else 
        @template.render :partial=>partial, :locals=>{ :card=>card, :slot=>self }.merge(locals)
      end
    end
    
    def process_transclusion( card, options={} )  
      #logger.info("<process_transclusion card=#{card.name} options=#{options}")
      subslot = subslot(card)  
      old_slot, @template.controller.slot = @template.controller.slot, subslot

      # FIXME! need a different test here   
      new_card = card.new_record? && !card.phantom?
      
      state, vmode = @state.to_sym, (options[:view] || :content).to_sym      
      subslot.requested_view = vmode
      #logger.info("<transclusion_case: state=#{state} vmode=#{vmode}")
      result = case
        when new_card && state==:line; subslot.render :missing_transclusion, options
        when new_card;     subslot.render( :create_transclusion, options ) 
        when state==:edit && card.phantom?; subslot.render :auto_card_notice
        when state==:edit;  subslot.render :edit_transclusion

        # this one takes precedence over state=view/line
        when vmode==:name;    subslot.render :name

        when state==:line; subslot.render(:expanded_line_content )
          
        # now we are in state==:view, switch on viewmode (from transclusion syntax)
        when vmode==:raw;     subslot.render :raw
        when vmode==:card;    subslot.render :view
        when vmode==:line;    subslot.render :line  
        when vmode==:link;    subslot.render :link
        when vmode==:content; subslot.render :content
      end
      @template.controller.slot = old_slot
      result
    end   
    
    def method_missing(method_id, *args, &proc) 
      @template.send(method_id, *args, &proc)
    end

    def custom_partial_for(action) 
      # FIXME: I like this method name better- maybe other calls should resolve here instead
      @template.partial_for_action(action, card)
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