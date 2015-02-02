format :html do 
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
  
  
  # FIELDSET VIEWS

  view :name_fieldset do |args|
    fieldset 'name', raw( name_field form ), :editor=>'name', :help=>args[:help]
  end

  view :type_fieldset do |args|
    field = if args[:variety] == :edit #FIXME dislike this api -ef
      type_field :class=>'type-field edit-type-field'
    else
      type_field :class=>"type-field live-type-field", :href=>path(:view=>:new), 'data-remote'=>true
    end
    fieldset 'type', field, :editor => 'type', :attribs => { :class=>'type-fieldset'}
  end


  view :button_fieldset do |args|
    %{
      <fieldset>
        <div class="button-area">
          #{ args[:buttons] }
        </div>
      </fieldset>
    }
  end

  view :content_fieldsets do |args|
    raw %{
      <div class="card-editor editor">
        #{ edit_slot args }
      </div>
    }
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


# FIELD VIEWS

  view :editor do |args|
    form.text_area :content, :rows=>3, :class=>'tinymce-textarea card-content', :id=>unique_id
  end


  view :edit_in_form, :perms=>:update, :tags=>:unknown_ok do |args|
    eform = form_for_multi
    content = content_field eform, args.merge( :nested=>true )
    opts = { :editor=>'content', :help=>true, :attribs =>
      { :class=> "card-editor RIGHT-#{ card.cardname.tag_name.safe_key }" }
    }
    if card.new_card?
      content += raw( "\n #{ eform.hidden_field :type_id }" )
    else
      opts[:attribs].merge! :card_id=>card.id, :card_name=>(h card.name)
    end
  
    fieldset fancy_title( args[:title] ), content, opts
  end

  def process_relative_tags args
    _render_raw(args).scan( /\{\{\s*\+[^\}]*\}\}/ ).map do |inc| #fixme - wrong place for regexp!
      process_content( inc ).strip
    end.join
  end
end