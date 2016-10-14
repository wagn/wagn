format :html do
  ###---( TOP_LEVEL (used by menu) NEW / EDIT VIEWS )

  view :new, perms: :create, tags: :unknown_ok do
    assign_new_view_title
    voo.show! :help
    frame_and_form :create, {}, "main-success" => "REDIRECT" do
      [new_hidden_fields,
       new_name_formgroup,
       new_type_formgroup,
       new_content_formgroup,
       new_buttons].compact
    end
  end

  def assign_new_view_title
    return if new_name_in_hidden_field?
    voo.title ||= generic_new_card_title
  end

  def new_content_formgroup
    content_formgroup
  end

  def new_name_formgroup help=nil
    return if hide_new_name_prompt?
    name_formgroup help
  end

  def hide_new_name_prompt?
    new_name_in_hidden_field? || card.rule_card(:autoname)
  end

  def new_name_in_hidden_field?
    card.cardname.present? && !params[:name_prompt]
  end

  def new_type_formgroup
    return if hide_new_type_formgroup?
    live_type_formgroup
  end

  def hide_new_type_formgroup?
    return @hide_new_type_formgroup unless @hide_new_type_formgroup.nil?
    @hide_new_type_formgroup = !show_new_type_formgroup?
  end

  def show_new_type_formgroup?
    !(params[:type] || voo.type) &&                   # type isn't already set
      (main? || card.simple? || card.is_template?) && # appropriate context
      Card.new(type_id: card.type_id).ok?(:create)
  end

  def new_hidden_fields
    fields = [hidden_success(card.rule :thanks)]
    fields << hidden_type unless show_new_type_formgroup?
    fields << hidden_name if new_name_in_hidden_field?
    fields << hidden_name_prompt unless hide_new_name_prompt?
    fields.join
  end

  def hidden_success override=nil
    hidden_field_tag "success", override || "_self"
  end

  def hidden_name
    hidden_field_tag "card[name]", card.name
  end

  def hidden_name_prompt
    hidden_field_tag "name_prompt", true
  end

  def hidden_type
    hidden_field_tag "card[type_id]", card.type_id
  end

  def generic_new_card_title
    if card.type_id == Card.default_type_id
      "New"
    else
      "New #{card.type_name}"
    end
  end

  def new_buttons
    cancel_path = !main? && path(view: :missing)
    button_formgroup do
      [standard_submit_button, standard_cancel_button(cancel_path)]
    end
  end

  view :edit, perms: :update, tags: :unknown_ok do
    voo.show! :toolbar, :help
    frame_and_form :update do
      [hidden_edit_fields, content_formgroup, edit_buttons]
    end
  end

  def hidden_edit_fields
    # for override
  end

  def edit_buttons
    button_formgroup do
      [standard_submit_button, standard_cancel_button]
    end
  end

  def standard_submit_button
    submit_button class: "submit-button"
  end

  def standard_cancel_button href=nil
    href ||= path
    cancel_button class: "cancel-button", href: href
  end

  view :edit_name, perms: :update do |args|
    voo.show! :toolbar
    frame_and_form({ action: :update, id: card.id },
                   args, "main-success" => "REDIRECT") do
      [hidden_edit_name_fields,
       name_formgroup,
       rename_confirmation_alert,
       edit_name_buttons]
    end
  end

  def hidden_edit_name_fields
    hidden_tags success:  "_self",
                old_name: card.name,
                card: { update_referers: false }
  end

  def edit_name_buttons
    button_formgroup do
      [rename_and_update_button, rename_button, standard_cancel_button]
    end
  end

  def rename_and_update_button
    submit_button text: "Rename and Update", disable_with: "Renaming",
                  class: "renamer-updater"
  end

  def rename_button
    button_tag "Rename", data: { disable_with: "Renaming" }, class: "renamer"
  end

  def rename_confirmation_alert
    msg = "<h5>Are you sure you want to rename <em>#{card.name}</em>?</h5>"
    msg << rename_effects_and_options
    alert("warning") { msg }
  end

  def rename_effects_and_options
    descendant_effect = rename_descendant_effect
    referer_effect, referer_option = rename_referer_effect_and_option
    effects = [descendant_effect, referer_effect].compact
    return "" if effects.empty?
    format_rename_effects_and_options effects, referer_option
  end

  def format_rename_effects_and_options effects, referer_option
    effects = effects.map { |effect| "<li>#{effect}</li>" }.join
    info = %(<h6>This change will...</h6>)
    info += %(<ul>#{effects}</ul>)
    info += %(<p>#{referer_option}</p>) if referer_option
    info
  end

  def rename_descendant_effect
    descendants = card.descendants
    return unless descendants.any? # FIXME: count, don't instantiate
    "automatically alter #{descendants.size} related name(s)."
  end

  def rename_referer_effect_and_option
    referers = card.family_referers
    return unless referers.any? # FIXME: count, don't instantiate
    count = referers.size
    refs = count == 1 ? "reference" : "references"
    effect = "affect at least #{count} #{refs} to \"#{card.name}\""
    option = "You may choose to <em>update or ignore</em> the referers."
    [effect, option]
  end

  view :edit_type, perms: :update do |args|
    voo.show! :toolbar
    frame_and_form :update, args do
      [
        hidden_edit_type_fields,
        standard_type_formgroup,
        edit_type_buttons
      ]
    end
  end

  def hidden_edit_type_fields
    hidden_field_tag "success[view]", "edit"
  end

  def edit_type_buttons
    cancel_path = path view: :edit
    button_formgroup do
      [standard_submit_button, standard_cancel_button(cancel_path)]
    end
  end

  view :edit_rules, tags: :unknown_ok do |args|
    voo.show! :set_navbar, :toolbar
    voo.hide! :set_label, :rule_navbar

    _render_related args.merge(
      related: {
        card: current_set_card,
        view: :open,
        slot: { rule_view: (args[:rule_view] || :common_rules) }
      }
    )
  end

  view :edit_structure do |args|
    voo.show! :toolbar
    slot_args =
      {
        cancel_slot_selector: ".card-slot.related-view",
        cancel_path: card.format.path(view: :edit),
        optional_edit_toolbar: :hide,
        hidden: { success: { view: :open, "slot[subframe]" => true } }
      }
    render_related args.merge(
      related: { card: card.structure, view: :edit, slot: slot_args }
    )
  end

  view :edit_nests do |args|
    voo.show! :toolbar
    frame args do
      with_nest_mode :edit do
        process_nested_fields optional_toolbar: :hide
      end
    end
  end

  view :edit_nest_rules do |args|
    voo.show! :toolbar
    view = args[:rule_view] || :field_related_rules
    frame args do
      # with_nest_mode :edit do
      nested_fields(args).map do |chunk|
        nest Card.fetch("#{chunk.referee_name}+*self"),
             view: :titled, title: chunk.referee_name, rule_view: view,
             optional_set_label: :hide,
             optional_rule_navbar: :show
      end
    end
  end
end
