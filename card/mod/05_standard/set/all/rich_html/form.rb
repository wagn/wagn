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
    
      if [ args[:optional_type_formgroup], args[:optional_name_formgroup] ].member? :show
        # display content field in formgroup for consistency with other fields
        formgroup '', field, :editor=>:content
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
      when String ;  [ card_path(action)     , nil             ] #deprecated
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

  def formgroup title, content, opts={}
    help_text = 
      case opts[:help]
      when String ; _render_help :help_class=>'help-block', :help_text=> opts[:help]
      when true   ; _render_help :help_class=>'help-block'
      else        ; nil
      end
      
    div_args = { :class=>['form-group', opts[:class]].compact*' ' }
    div_args[:card_id  ] = card.id     if card.real?
    div_args[:card_name] = h card.name if card.name.present? 
      
    wrap_with :div, div_args do
      %{
        <label>#{ title }</label>
        <div>
          #{ editor_wrap( opts[:editor] ) { content } }
          #{ help_text }            
        </div>
      }
    end
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

  view :name_formgroup do |args|
    formgroup 'name', raw( name_field form ), :editor=>'name', :help=>args[:help]
  end

  view :type_formgroup do |args|
    field = if args[:variety] == :edit #FIXME dislike this api -ef
      type_field :class=>'type-field edit-type-field'
    else
      type_field :class=>"type-field live-type-field", :href=>path(:view=>:new), 'data-remote'=>true
    end
    formgroup 'type', field, :editor => 'type', :class=>'type-formgroup'
  end


  view :button_formgroup do |args|
    %{<div class="form-group"><div>#{ args[:buttons] }</div></div>}
  end

  view :content_formgroups do |args|
    raw %{
      <fieldset class="card-editor editor">
        #{ edit_slot args }
      </fieldset>
    }
  end


  def name_field form=nil, options={}
    form ||= self.form
    text_field( :name, {
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
      hidden_field :last_action_id_before_edit, :class=>'current_revision_id'
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
    text_area :content, :rows=>3, :class=>'tinymce-textarea card-content', :id=>unique_id, "data-card-type-code"=>card.type_code
  end

  view :edit_in_form, :perms=>:update, :tags=>:unknown_ok do |args|
    eform = form_for_multi
    
    content = content_field eform, args.merge( :nested=>true )
    opts = { :editor=>'content', :help=>true, :class=>'card-editor' }
    
    content      += raw( "\n #{ eform.hidden_field :type_id }" )     if card.new_card?
    opts[:class] += " RIGHT-#{ card.cardname.tag_name.safe_key }"   if card.cardname.junction?
  
    formgroup fancy_title( args[:title] ), content, opts
  end

  def process_relative_tags args
    _render_raw(args).scan( /\{\{\s*\+[^\}]*\}\}/ ).map do |inc| #fixme - wrong place for regexp!
      process_content( inc ).strip
    end.join
  end

  # form helpers
  
  FIELD_HELPERS = %w{hidden_field color_field date_field datetime_field datetime_local_field
    email_field month_field number_field password_field phone_field
    range_field search_field telephone_field text_area text_field time_field
    url_field week_field file_field}


  FIELD_HELPERS.each do |method_name|
    define_method(method_name) do |name, options = {}|
      form.send(method_name, name, options)
    end
  end
  
  def check_box method, options={}, checked_value = "1", unchecked_value = "0"
    form.check_box method, options, checked_value, unchecked_value
  end
  
  def radio_button method, tag_value, options = {}
    form.radio_button method, tag_value, options
  end
  
end
