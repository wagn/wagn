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
      self.class.tagged view, :comment                                   and 
      show_view? :comment_box, args.merge( :default_visibility=>:hide )  and #developer or wagneer has overridden default
      ok? :comment
    end

    def get_layout_content
      Auth.as_bot do
        if requested_layout = params[:layout]
          layout_from_card_or_code requested_layout
        else
          layout_from_rule
        end
      end
    end

    def layout_from_rule
      if rule = card.rule_card(:layout) and rule.type_id==Card::PointerID and layout_name=rule.item_names.first
        layout_from_card_or_code layout_name
      end
    end

    def layout_from_card_or_code name
      layout_card = Card.fetch name.to_s, :skip_virtual=>true, :skip_modules=>true
      if layout_card and layout_card.ok? :read
        layout_card.content
      elsif hardcoded_layout = LAYOUTS[name]
        hardcoded_layout
      else
        "<h1>Unknown layout: #{name}</h1>Built-in Layouts: #{LAYOUTS.keys.join(', ')}"
      end
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
    
      div = %{<div id="#{card.cardname.url_key}" data-card-id="#{card.id}" data-card-name="#{h card.name}" data-card-type-code="#{card.type_code}" style="#{h args[:style]}" class="#{classes*' '}" } +
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

    # session history helpers: we keep a history stack so that in the case of
    # card removal we can crawl back up to the last un-removed location

    module Location
      def location_history
        #warn "sess #{session.class}, #{session.object_id}"
        session[:history] ||= [wagn_path('')]
        if session[:history]
          session[:history].shift if session[:history].size > 5
          session[:history]
        end
      end

      def save_location
        return if ajax? || !html? || !@card.known? || (@card.codename == 'signin')
        discard_locations_for @card
        @previous_location = wagn_path @card.cardname.url_key
        location_history.push @previous_location
      end

      def previous_location
        @previous_location ||= location_history.last if location_history
      end

      def discard_locations_for(card)
        # quoting necessary because cards have things like "+*" in the names..
        session[:history] = location_history.reject do |loc|
          if url_key = url_key_for_location(loc)
            url_key.to_name.key == card.key
          end
        end.compact
        @previous_location = nil
      end

      def save_interrupted_action uri
        uri = path(uri) if Hash === uri
        session[:interrupted_action] = uri
      end
  
      def interrupted_action
        session.delete :interrupted_action
      end

      def url_key_for_location(location)
        location.match( /\/([^\/]*$)/ ) ? $1 : nil
      end
    end
    include Location

    def rendering_error exception, view
      %{
        <span class="render-error">
          error rendering
          #{
            if Auth.always_ok?
              %{
                #{ build_link error_cardname, nil, :class=>'render-error-link' }
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
  
    def unsupported_view view
      "<strong>view <em>#{view}</em> not supported for <em>#{error_cardname}</em></strong>"
    end

    def final_link href, opts={}
      text = (opts.delete(:text) || href).dup
      content_tag :a, text, opts.merge(:href=>href)
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
      card.last_action_id_before_edit = card.last_action_id
      revision_tracking = if card && !card.new_card? && !options[:skip_rev_id]
        form.hidden_field :last_action_id_before_edit, :class=>'current_revision_id'
        #hidden_field_tag 'card[last_action_id_before_edit]', card.last_action_id, :class=>'current_revision_id'
      end
      %{
        #{ revision_tracking 
         }
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
    
      html[:recaptcha] ||= 'on' if card.recaptcha_on?
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
        @depth == 1 && @mainline #assumes layout includes {{_main}}
      end
    end

    private

    def fancy_title title=nil
      raw %{<span class="card-title">#{ showname(title).to_name.parts.join %{<span class="joint">+</span>} }</span>}
    end
  end
end
