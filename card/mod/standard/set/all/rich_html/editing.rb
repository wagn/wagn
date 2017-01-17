format :html do
  ###---( TOP_LEVEL (used by menu) NEW / EDIT VIEWS )
  view :edit, perms: :update, tags: :unknown_ok, cache: :never do
    voo.show :toolbar, :help
    frame_and_form :update do
      [
        edit_view_hidden,
        _optional_render_content_formgroup,
        _optional_render_edit_buttons
      ]
    end
  end

  def edit_view_hidden
    # for override
  end

  view :edit_buttons do
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

  view :edit_name, perms: :update do
    voo.show :toolbar
    frame_and_form({ action: :update, id: card.id },
                   "main-success" => "REDIRECT") do
      [hidden_edit_name_fields,
       _optional_render_name_formgroup,
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
    effect += hidden_field_tag(:referers, count)
    option = "You may choose to <em>update or ignore</em> the referers."
    [effect, option]
  end

  view :edit_type, cache: :never, perms: :update do
    voo.show :toolbar
    frame_and_form :update do
      [
        hidden_edit_type_fields,
        _render_type_formgroup,
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

  view :edit_rules, cache: :never, tags: :unknown_ok do |args|
    voo.show :set_navbar, :toolbar
    voo.hide :set_label, :rule_navbar

    _render_related args.merge(
      related: {
        card: current_set_card,
        view: :open
      }
    )
  end

  view :edit_structure, cache: :never do |args|
    voo.show :toolbar
    render_related args.merge(
      related: {
        card: card.structure,
        view: :edit
      }
      # FIXME: this stuff:
      #  slot: {
      #    cancel_slot_selector: ".card-slot.related-view",
      #    cancel_path: card.format.path(view: :edit), hide: :edit_toolbar,
      #    hidden: { success: { view: :open, "slot[subframe]" => true } }
      #  }
      # }
    )
  end

  view :edit_nests, cache: :never do
    voo.show :toolbar
    frame do
      with_nest_mode :edit do
        process_nested_fields hide: :toolbar
      end
    end
  end

  view :edit_nest_rules, cache: :never do |args|
    return ""
    # FIXME - view can recurse.  temporarily turned off
    voo.show :toolbar
    view = args[:rule_view] || :field_related_rules
    frame do
      # with_nest_mode :edit do
      nested_fields.map do |name, _options|
        nest Card.fetch(name.to_name.trait(:self)),
             view: :titled, title: name, rule_view: view,
             hide: :set_label, show: :rule_navbar
      end
    end
  end
end
