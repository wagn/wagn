include_set Abstract::ProsemirrorEditor

format :html do
  def edit_slot args={}
    # note: @mode should already be :edit here...
    if args[:structure] || card.structure ||
       args[:edit_fields]
      multi_card_edit_slot args
    else
      single_card_edit_slot args
    end
  end

  def multi_card_edit_slot args
    if args[:core_edit] # need better name
      _render_core args
    elsif args[:edit_fields]
      process_edit_fields args[:edit_fields]
    else
      process_nested_fields optional_toolbar: :hide,
                            structure: args[:structure]
    end
  end

  def single_card_edit_slot args
    field = content_field form, args
    if [args[:optional_type_formgroup], args[:optional_name_formgroup]]
       .member? :show
      # display content field in formgroup for consistency with other fields
      formgroup "", field, editor: :content
    else
      editor_wrap(:content) { field }
    end
  end

  def process_nested_fields args
    nested_fields(args).map do |chunk|
      nest chunk.options.reverse_merge(args)
    end.join "\n"
  end

  # @param [Hash|Array] fields either an array with field names and/or field
  # cards or a hash with the fields as keys and a hash with nest options as
  # values
  def process_edit_fields fields
    fields.map do |field, opts|
      field_nest field, opts
    end.join "\n"
  end

  def form_for_multi
    instantiate_builder("card#{subcard_input_names}", card, {})
  end

  def subcard_input_names
    return "" if !form_root_format || form_root_format == self
    "#{@parent.subcard_input_names}[subcards][#{card.contextual_name}]"
  end

  def form
    @form ||= form_for_multi
  end

  def card_form action, opts={}
    @form_root = true
    hidden_args = opts.delete :hidden
    form_for card, card_form_opts(action, opts) do |form|
      @form = form
      %(
        #{hidden_tags hidden_args if hidden_args}
        #{yield form}
      )
    end
  end

  def form_root_format
    if @form_root
      self
    elsif !@parent
      nil
    else
      @parent.form_root_format
    end
  end

  def card_form_opts action, html={}
    url, action = url_from_action(action)

    klasses = Array.wrap(html[:class])
    klasses << "card-form slotter"
    klasses << "autosave" if action == :update
    html[:class] = klasses.join " "

    html[:recaptcha] ||= "on" if card.recaptcha_on?
    html.delete :recaptcha if html[:recaptcha] == :off

    { url: url, remote: true, html: html }
  end

  def url_from_action action
    case action
    when Symbol
      [path(action: action), action]
    when Hash
      [path(action), action[:action]]
    when String # deprecated
      [card_path(action), nil]
    else
      raise Card::Error, "unsupported card_form action class: #{action.class}"
    end
  end

  def editor_wrap type=nil
    html_class = "editor"
    html_class << " #{type}-editor" if type
    content_tag(:div, class: html_class) { yield.html_safe }
  end

  def formgroup title, content, opts={}
    wrap_with :div, formgroup_div_args(opts[:class]) do
      %(
        #{form.label(opts[:editor] || :content, title)}
        <div>
          #{editor_wrap(opts[:editor]) { content }}
          #{formgroup_help_text opts[:help]}
        </div>
      )
    end
  end

  def formgroup_div_args html_class
    div_args = { class: ["form-group", html_class].compact.join(" ") }
    div_args[:card_id] = card.id if card.real?
    div_args[:card_name] = h card.name if card.name.present?
    div_args
  end

  def formgroup_help_text text=nil
    case text
    when String then _render_help help_class: "help-block", help_text: text
    when true   then _render_help help_class: "help-block"
    end
  end

  def hidden_tags hash, base=nil
    # convert hash into a collection of hidden tags
    result = ""
    hash ||= {}
    hash.each do |key, val|
      result +=
        if val.is_a?(Hash)
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
    formgroup "name", raw(name_field(form)),
              editor: "name", help: args[:help]
  end

  view :type_formgroup do |args|
    field = if args[:variety] == :edit # FIXME: dislike this api -ef
              type_field class: "type-field edit-type-field"
            else
              type_field class: "type-field live-type-field",
                         href: path(view: :new), "data-remote" => true
            end
    formgroup "type", field, editor: "type", class: "type-formgroup"
  end

  view :button_formgroup do |args|
    %(<div class="form-group"><div>#{args[:buttons]}</div></div>)
  end

  view :content_formgroup do |args|
    raw %(
      <fieldset class="card-editor editor">
        #{edit_slot args}
      </fieldset>
    )
  end

  def name_field form=nil, options={}
    form ||= self.form
    text_field(:name, {
      # needed because otherwise gets wrong value if there are updates
      value: card.name,
      autocomplete: "off"
    }.merge(options))
  end

  def type_field args={}
    typelist = Auth.createable_types
    current_type =
      unless args.delete :no_current_type
        if !card.new_card? && !typelist.include?(card.type_name)
          # current type should be an option on existing cards,
          # regardless of create perms
          typelist.push(card.type_name).sort!
        end
        card.type_name_or_default
      end

    options = options_from_collection_for_select typelist, :to_s, :to_s,
                                                 current_type
    template.select_tag "card[type]", options, args
  end

  def content_field form, options={}
    @form = form
    @nested = options[:nested]
    card.last_action_id_before_edit = card.last_action_id
    revision_tracking =
      if card && !card.new_card? && !options[:skip_rev_id]
        hidden_field :last_action_id_before_edit, class: "current_revision_id"
        # hidden_field_tag 'card[last_action_id_before_edit]',
        # card.last_action_id, class: 'current_revision_id'
      end
    %(
      #{revision_tracking}
      #{_render_editor options}
    )
  end

  # FIELD VIEWS

  view :edit_in_form, perms: :update, tags: :unknown_ok do |args|
    eform = form_for_multi
    content = content_field eform, args.merge(nested: true)
    content += raw("\n #{eform.hidden_field :type_id}") if card.new_card?
    opts = { editor: "content", help: true, class: "card-editor" }
    if card.cardname.junction?
      opts[:class] += " RIGHT-#{card.cardname.tag_name.safe_key}"
    end
    formgroup fancy_title(args[:title]), content, opts
  end

  # form helpers

  FIELD_HELPERS =
    %w(
      hidden_field color_field date_field datetime_field datetime_local_field
      email_field month_field number_field password_field phone_field
      range_field search_field telephone_field text_area text_field time_field
      url_field week_field file_field
    ).freeze

  FIELD_HELPERS.each do |method_name|
    define_method(method_name) do |name, options={}|
      form.send(method_name, name, options)
    end
  end

  def check_box method, options={}, checked_value="1", unchecked_value="0"
    form.check_box method, options, checked_value, unchecked_value
  end

  def radio_button method, tag_value, options={}
    form.radio_button method, tag_value, options
  end

  def submit_button args={}
    args.reverse_merge!(
      situation: "primary",
      data: {}
    )
    text = args.delete(:text) || "Submit"
    args[:data][:disable_with] ||= args.delete(:disable_with) || "Submitting"
    button_tag text, args
  end

  # redirect to *previous if no :href is given
  def cancel_button args={}
    args.reverse_merge! type: "button"
    if args[:href]
      add_class args, "slotter"
    else
      add_class args, "redirecter"
      args[:href] = Card.path_setting("/*previous")
    end
    text = args.delete(:text) || "Cancel"
    button_tag text, args
  end
end
