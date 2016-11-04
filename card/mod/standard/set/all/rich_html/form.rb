include_set Abstract::ProsemirrorEditor

format :html do
  def edit_slot core_edit=false
    if core_edit || voo.structure || card.structure
      multi_card_edit_slot core_edit
    else
      single_card_edit_slot
    end
  end

  def multi_card_edit_slot core_edit
    if core_edit # need better name
      _render_core # FIXME:  get options from voo?  eg structure?
    else
      process_nested_fields
    end
  end

  def single_card_edit_slot
    if voo.show?(:type_formgroup) || voo.show?(:name_formgroup)
      # display content field in formgroup for consistency with other fields
      formgroup("", editor: :content) { content_field }
    else
      editor_wrap(:content) { content_field }
    end
  end

  def process_nested_fields
    nested_fields.map do |_name, options|
      options[:hide] = :toolbar
      nest options[:nest_name], options
    end.join "\n"
  end

  # @param [Hash|Array] fields either an array with field names and/or field
  # cards or a hash with the fields as keys and a hash with nest options as
  # values
  # def process_edit_fields fields
  #   fields.map do |field, opts|
  #     field_nest field, opts
  #   end.join "\n"
  # end

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
    url, action = card_form_url action
    html_opts = card_form_html_opts action, opts
    form_for card, url: url, html: html_opts, remote: true do |form|
      @form = form
      output yield(form)
    end
  end

  def form_root_format
    if @form_root   then self
    elsif !@parent  then nil
    else                 @parent.form_root_format
    end
  end

  def card_form_html_opts action, opts={}
    klasses = Array.wrap(opts[:class]) << "card-form slotter"
    klasses << "autosave" if action == :update
    opts[:class] = klasses.join " "

    opts[:recaptcha] ||= "on" if card.recaptcha_on?
    opts.delete :recaptcha if opts[:recaptcha] == :off
    opts
  end

  def card_form_url action
    case action
    when Symbol then [path(action: action), action]
    when Hash   then [path(action), action[:action]]
      # for when non-action path args are required
    else
      raise Card::Error, "unsupported #card_form_url action: #{action}"
    end
  end

  def editor_wrap type=nil
    html_class = "editor"
    html_class << " #{type}-editor" if type
    wrap_with :div, class: html_class do
      yield
    end
  end

  def formgroup title, opts={}, &block
    label = formgroup_label opts[:editor], title
    editor_body = editor_wrap opts[:editor], &block
    help_text = formgroup_help_text opts[:help]
    wrap_with :div, formgroup_div_args(opts[:class]) do
      "#{label} #{help_text}<div>#{editor_body}</div>"
    end
  end

  def formgroup_label editor_type, title
    label_type = editor_type || :content
    form.label label_type, title
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

  view :name_formgroup do
    formgroup "name", editor: "name" do
      raw name_field
    end
  end

  def wrap_type_formgroup
    formgroup "type", editor: "type", class: "type-formgroup" do
      yield
    end
  end

  view :type_formgroup do
    wrap_type_formgroup do
      type_field class: "type-field edit-type-field"
    end
  end

  def button_formgroup
    buttons = Array.wrap(yield).join "\n"
    %(<div class="form-group"><div>#{buttons}</div></div>)
  end

  view :content_formgroup do
    wrap_with :fieldset, edit_slot, class: classy("card-editor", "editor")
  end

  def name_field
    # value needed because otherwise gets wrong value if there are updates
    text_field :name, value: card.name, autocomplete: "off"
  end

  def type_field args={}
    typelist = Auth.createable_types
    current_type = type_field_current_value args, typelist
    options = options_from_collection_for_select typelist, :to_s, :to_s,
                                                 current_type
    template.select_tag "card[type]", options, args
  end

  def type_field_current_value args, typelist
    return if args.delete :no_current_type
        if !card.new_card? && !typelist.include?(card.type_name)
          # current type should be an option on existing cards,
          # regardless of create perms
          typelist.push(card.type_name).sort!
        end
        card.type_name_or_default
      end

  def content_field skip_rev_id=false
    [content_field_revision_tracking(skip_rev_id), _render_editor].compact.join
  end

  def content_field_revision_tracking skip_rev_id
    card.last_action_id_before_edit = card.last_action_id
    return if !card || card.new_card? || skip_rev_id
        hidden_field :last_action_id_before_edit, class: "current_revision_id"
  end

  # FIELD VIEWS

  view :edit_in_form, cache: :never, perms: :update, tags: :unknown_ok do
    @form = form_for_multi
    add_junction_class
    formgroup fancy_title(voo.title),
              editor: "content", help: true, class: classy("card-editor") do
      [content_field, (form.hidden_field(:type_id) if card.new_card?)]
    end
    end

  def add_junction_class
    return unless card.cardname.junction?
    class_up "card-editor", "RIGHT-#{card.cardname.tag_name.safe_key}"
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
    text = args.delete(:text) || "Submit"
    args.reverse_merge! situation: "primary", data: {}
    args[:data][:disable_with] ||= args.delete(:disable_with) || "Submitting"
    button_tag text, args
  end

  # redirect to *previous if no :href is given
  def cancel_button args={}
    text = args.delete(:text) || "Cancel"
    args[:type] ||= "button"
    add_class args, (args[:href] ? "slotter" : "redirecter")
    args[:href] ||= Card.path_setting("/*previous")
    button_tag text, args
  end
end
