# -*- encoding : utf-8 -*-

require_dependency 'card/diff'

class Card
  Format.register :html
  class HtmlFormat < Format
    include Diff
  
    attr_accessor  :options_need_save, :start_time, :skip_autosave

    # builtin layouts allow for rescue / testing
    LAYOUTS = Loader.load_layouts.merge 'none' => '{{_main}}'

    INCLUSION_DEFAULTS = {
      :layout => { :view => :core },
      :normal => { :view => :content }
    }
  
    def get_inclusion_defaults
      INCLUSION_DEFAULTS[@mode] || {}
    end
  
    def default_item_view
      :closed
    end

    def view_for_unknown view, args
      case
      when focal? && ok?( :create )   ;  :new
      when commentable?( view, args ) ;  view
      else                               super
      end
    end

    def commentable? view, args
      self.class.tagged view, :comment      and 
      show_view? :comment_box, args, :hide and #developer or wagneer has overridden default
      ok? :comment
    end

    def get_layout_content(args)
      Auth.as_bot do
        case
          when (params[:layout] || args[:layout]) ;  layout_from_name args
          when card                               ;  layout_from_card
          else                                    ;  LAYOUTS['default']
        end
      end
    end

    def layout_from_name args
      lname = (params[:layout] || args[:layout]).to_s
      lcard = Card.fetch(lname, :skip_virtual=>true, :skip_modules=>true)
      case
        when lcard && lcard.ok?(:read)         ; lcard.content
        when hardcoded_layout = LAYOUTS[lname] ; hardcoded_layout
        else  ; "<h1>Unknown layout: #{lname}</h1>Built-in Layouts: #{LAYOUTS.keys.join(', ')}"
      end
    end

    def layout_from_card
      return unless rule_card = (card.rule_card(:layout) or Card.default_rule_card(:layout))
      #return unless rule_card.is_a?(Card::Set::Type::Pointer) and  # type check throwing lots of warnings under cucumber: rule_card.type_id == Card::PointerID        and
      return unless rule_card.type_id == Card::PointerID        and
          layout_name=rule_card.item_names.first                and
          !layout_name.nil?                                     and
          lo_card = Card.fetch( layout_name, :skip_virtual => true, :skip_modules=>true ) and
          lo_card.ok?(:read)
      lo_card.content
    end

    def slot_options args
      @@slot_option_keys ||= Card::Chunk::Include.options.reject { |k| k == :view }.unshift :home_view
      options_hash = {}
    
      if @context_names.present?
        options_hash['name_context'] = @context_names.map( &:key ) * ','
      end
    
      @@slot_option_keys.inject(options_hash) do |hash, opt|
        hash[opt] = args[opt] if args[opt].present?
        hash
      end
    
      JSON( options_hash )
    end

    def wrap args = {}
      classes = [
        ( 'card-slot' unless args[:no_slot] ),
        "#{ @current_view }-view",
        ( args[:slot_class] if args[:slot_class] ),
        ( "STRUCTURE-#{args[:structure].to_name.key}" if args[:structure]),
        card.safe_set_keys
      ].compact
    
      div = %{<div id="#{card.cardname.url_key}" data-card-id="#{card.id}" data-card-name="#{h card.name}" style="#{h args[:style]}" class="#{classes*' '}" } +
        %{data-slot='#{html_escape_except_quotes slot_options( args )}'>#{ output yield }</div>}

      if params[:debug] == 'slot' && !tagged( @current_view, :no_wrap_comments )
        name = h card.name
        space = '  ' * @depth
        %{<!--\n\n#{ space }BEGIN SLOT: #{ name }\n\n-->#{ div }<!--\n\n#{space}END SLOT: #{ name }\n\n-->}
      else
        div
      end
    end
  
    def wrap_body args={}
      css_classes = [ 'card-body' ]
      css_classes << args[:body_class]                  if args[:body_class]
      css_classes += [ 'card-content', card.safe_set_keys ] if args[:content]
      content_tag :div, :class=>css_classes.compact*' ' do
        yield args
      end
    end
    
    def frame args={}
      wrap args.merge(:slot_class=>'card-frame') do
        %{
          #{ _render_header args }
          #{ %{ <div class="card-subheader">#{ args[:subheader] }</div> } if args[:subheader] }
          #{ _optional_render :help, args, :hide }
          #{ wrap_body args do output( yield args ) end }
        }
      end
    end
  
    def frame_and_form action, args={}, form_opts={}
      form_opts.merge! args.delete(:form_opts) if args[:form_opts]
      form_opts[:hidden] = args.delete(:hidden)
      frame args do
        card_form action, form_opts do
          output( yield args )
        end
      end
    end
  
    def output content
      case content
      when String; content
      when Array ; content.compact.join "\n"
      end
    end  


    def wrap_main(content)
      return content if params[:layout]=='none'
      %{<div id="main">#{content}</div>}
    end

  
    def html_escape_except_quotes s
      # to be used inside single quotes (makes for readable json attributes)
      s.to_s.gsub(/&/, "&amp;").gsub(/\'/, "&apos;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
    end


    def edit_slot args={}
      #note: @mode should already be :edit here...
      if args[:structure] || card.structure
        # multi-card editing
      
        if args[:core_edit] #need better name!
          _render_core args
        else
          process_relative_tags args
        end

      else
        # single-card edit mode
        field = content_field form, args
      
        if [ args[:optional_type_fieldset], args[:optional_name_fieldset] ].member? :show
          # display content field in fieldset for consistency with other fields
          fieldset '', field, :editor=>:content
        else
          editor_wrap( :content ) { field }
        end
      end
    end
  
    def process_relative_tags args
      _render_raw(args).scan( /\{\{\s*\+[^\}]*\}\}/ ).map do |inc| #fixme - wrong place for regexp!
        process_content( inc ).strip
      end.join    
    end
  
  

    #### --------------------  additional helpers ---------------- ###

    def rendering_error exception, view
      %{
        <span class="render-error">
          error rendering
          #{
            if Auth.always_ok?
              %{
                #{ link_to_page error_cardname, nil, :class=>'render-error-link' }
                <div class="render-error-message errors-view" style="display:none">
                  <h3>Error message (visible to admin only)</h3>
                  <p><strong>#{ exception.message }</strong></p>
                  <div>
                    #{exception.backtrace * "<br>\n"}
                  </div>
                </div>
              }
            else
              error_cardname
            end
          }
          (#{view} view)
        </span>
      }
    end
  
    def unknown_view view
      "<strong>unknown view: <em>#{view}</em></strong>"
    end
  
    def unsupported_view view
      "<strong>view <em>#{view}</em> not supported for <em>#{error_cardname}</em></strong>"
    end

    def final_link href, opts={}
      text = opts[:text] || href
      %{<a class="#{opts[:class]}" href="#{href}">#{text}</a>}
    end

    def link_to_view text, view, opts={}
      path_opts = view==:home ? {} : { :view=>view }
      if p = opts.delete( :path_opts )
        path_opts.merge! p
      end
      opts[:remote] = true
      opts[:rel] = 'nofollow'
      link_to text, path( path_opts ), opts
    end

    def name_field form=nil, options={}
      form ||= self.form
      form.text_field( :name, {
        :value=>card.name, #needed because otherwise gets wrong value if there are updates
        :autocomplete=>'off'
      }.merge(options))
    end

    def type_field args={}
      typelist = Auth.createable_types
      current_type = unless args.delete :no_current_type
          unless card.new_card? || typelist.include?( card.type_name )
            # current type should be an option on existing cards, regardless of create perms
            typelist = (typelist << card.type_name).sort
          end
          Card[ card ? card.type_id : Card.default_type_id ].name
        end

      options = options_from_collection_for_select typelist, :to_s, :to_s, current_type
      template.select_tag 'card[type]', options, args
    end

    def content_field form, options={}
      @form = form
      @nested = options[:nested]
      revision_tracking = if card && !card.new_card? && !options[:skip_rev_id]
        form.hidden_field :current_revision_id, :class=>'current_revision_id'
      end
      %{
        #{ revision_tracking }
        #{ _render_editor options }
      }
    end

    def form_for_multi
      block = Proc.new {}
      builder = ActionView::Base.default_form_builder
      card.name = card.name.gsub(/^#{Regexp.escape(root.card.name)}\+/, '+') if root.card.new_card?  ##FIXME -- need to match other relative inclusions.
    
      builder.new("card[subcards][#{card.relative_name}]", card, template, {}, block)
    end

    def form
      @form ||= form_for_multi
    end

    def card_form action, opts={}
      hidden_args = opts.delete :hidden
      form_for card, card_form_opts(action, opts) do |form|
        @form = form
        %{
          #{ hidden_tags hidden_args if hidden_args }
          #{ yield form }
        }
      end
    end

    def card_form_opts action, html={}
      url, action = case action
        when Symbol ;  [ path(:action=>action) , action          ]
        when Hash   ;  [ path(action)          , action[:action] ]
        when String ;  [ wagn_path(action)     , nil             ] #deprecated
        else        ;  raise Card::Error, "unsupported card_form action class: #{action.class}"
        end
      
      klasses = Array.wrap( html[:class] )
      klasses << 'card-form slotter'
      klasses << 'autosave' if action == :update
      html[:class] = klasses.join ' '
    
      html[:recaptcha] ||= 'on' if Card::Env.recaptcha_on? && Card.toggle( card.rule(:captcha) )
      html.delete :recaptcha if html[:recaptcha] == :off
    
      { :url=>url, :remote=>true, :html=>html }
    end

    def editor_wrap type=nil
      content_tag( :div, :class=>"editor#{ " #{type}-editor" if type }" ) { yield }
    end

    def fieldset title, content, opts={}
      if attribs = opts[:attribs]
        attrib_string = attribs.keys.map do |key| 
          %{#{key}="#{attribs[key]}"}
        end * ' '
      end
      help_text = case opts[:help]
        when String ; _render_help :help_text=> opts[:help]
        when true   ; _render_help
        else        ; nil
      end
      %{
        <fieldset #{ attrib_string }>
          <legend>
            <h2>#{ title }</h2>
            #{ help_text }
          </legend>
          #{ editor_wrap( opts[:editor] ) { content } }
        </fieldset>
      }
    end
  
    def hidden_tags hash, base=nil
      # convert hash into a collection of hidden tags
      result = ''
      hash ||= {}
      hash.each do |key, val|
        result += if Hash === val
          hidden_tags val, key
        else
          name = base ? "#{base}[#{key}]" : key
          hidden_field_tag name, val
        end
      end
      result
    end

    def main?
      if Env.ajax?
        @depth == 0 && params[:is_main]
      else
        @depth == 1 && @mainline
      end
    end

    private

    def fancy_title title=nil
      raw %{<span class="card-title">#{ showname(title).to_name.parts.join %{<span class="joint">+</span>} }</span>}
    end
  end
end
