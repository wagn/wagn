

format :html do
  # FIELDSET VIEWS
  view :content_formgroup, cache: :never do
    wrap_with :fieldset, edit_slot, class: classy("card-editor", "editor")
  end

  view :name_formgroup do
    formgroup "name", editor: "name", help: false do
      raw name_field
    end
  end

  view :type_formgroup do
    wrap_type_formgroup do
      type_field class: "type-field edit-type-field"
    end
  end

  view :edit_in_form, cache: :never, perms: :update, tags: :unknown_ok do
    @form = form_for_multi
    multi_edit_slot
  end

  def wrap_type_formgroup
    formgroup "type", editor: "type", class: "type-formgroup", help: false do
      yield
    end
  end

  def button_formgroup
    wrap_with :div, class: "form-group" do
      wrap_with :div, yield
    end
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
    with_nest_mode :normal do
      # by changing nest mode to normal, we ensure that editors (eg image
      # previews) can render core views.
      output [content_field_revision_tracking(skip_rev_id), _render_editor]
    end
  end

  # SAMPLE editor view for override
  # view :editor do
  #   text_area :content, rows: 5, class: "card-content"
  # end

  def content_field_revision_tracking skip_rev_id
    card.last_action_id_before_edit = card.last_action_id
    return if !card || card.new_card? || skip_rev_id
    hidden_field :last_action_id_before_edit, class: "current_revision_id"
  end

  def edit_slot
    if inline_nests_editor?
      _render_core
    elsif multi_edit?
      process_nested_fields
    else
      single_card_edit_slot
    end
  end

  def multi_edit_slot
    if inline_nests_editor?
      _render_core
    elsif multi_edit?
      process_nested_fields
    else
      multi_card_edit_slot
    end
  end

  def multi_edit?
    nests_editor? || # editor configured in voo
      voo.structure || voo.edit_structure || # structure configured in voo
      card.structure                         # structure in card rule
  end

  def inline_nests_editor?
    voo.editor == :inline_nests
  end

  def nests_editor?
    voo.editor == :nests
  end

  def single_card_edit_slot
    if voo.show?(:type_formgroup) || voo.show?(:name_formgroup)
      # display content field in formgroup for consistency with other fields
      formgroup("", editor: :content, help: false) { content_field }
    else
      editor_wrap(:content) { content_field }
    end
  end

  def multi_card_edit_slot
    add_junction_class
    formgroup fancy_title(voo.title),
              editor: "content", help: true, class: classy("card-editor") do
      [content_field, (form.hidden_field(:type_id) if card.new_card?)]
    end
  end

  def process_nested_fields
    nested_fields_for_edit.map do |name, options|
      options[:hide] = [options[:hide], :toolbar].compact
      nest name, options
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
    return @parent.subcard_input_names if @parent.card == card
    "#{@parent.subcard_input_names}[subcards][#{name_in_form}]"
  end

  # If you use subfield cards to render a form for a new card
  # then the subfield cards should be created on the new card not the existing
  # card that build the form
  def name_in_form
    relative_names_in_form? ? card.relative_name : card.contextual_name
  end

  def form
    @form ||= form_for_multi
  end

  def card_form action, opts={}
    @form_root = true
    success = opts.delete(:success)
    form_for card, card_form_opts(action, opts) do |form|
      @form = form
      success_tags(success) + output(yield(form))
    end
  end

  # use relative names in the form
  def relative_card_form action, opts={}, &block
    with_relative_names_in_form do
      card_form action, opts, &block
    end
  end

  def form_root_format
    if @form_root   then self
    elsif !@parent  then nil
    else                 @parent.form_root_format
    end
  end

  # @param action [Symbol] :create or :update
  # @param opts [Hash] html options
  # @option opts [Boolean] :redirect (false) if true form is no "slotter"
  def card_form_opts action, opts={}
    url, action = card_form_url_and_action action
    html_opts = card_form_html_opts action, opts
    form_opts = { url: url, html: html_opts }
    form_opts[:remote] = true unless html_opts.delete(:redirect)
    form_opts
  end

  def card_form_html_opts action, opts={}
    add_class opts, "card-form"
    add_class opts, "slotter" unless opts[:redirect]
    add_class opts, "autosave" if action == :update
    opts[:recaptcha] ||= "on" if card.recaptcha_on?
    opts.delete :recaptcha if opts[:recaptcha] == :off
    opts
  end

  def card_form_url_and_action action
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

  def with_relative_names_in_form
    @relative_names_in_form = true
    result = yield
    @relative_names_in_form = nil
    result
  end

  def relative_names_in_form?
    @relative_names_in_form || (parent && parent.relative_names_in_form?)
  end

  # FIELD VIEWS

  def add_junction_class
    return unless card.cardname.junction?
    class_up "card-editor", "RIGHT-#{card.cardname.tag_name.safe_key}"
  end
end
