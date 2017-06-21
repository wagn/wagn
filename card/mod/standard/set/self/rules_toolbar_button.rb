include_set Abstract::ToolbarSplitButton

format :html do
  view :core do
    subject.toolbar_split_button("rules", view: :edit_rules, icon: :list) do
      dropdown_items
    end
  end

  def dropdown_items
    button_hash = {
      common_rules:  edit_rules_link("common",   :common_rules),
      grouped_rules: edit_rules_link("by group", :grouped_rules),
      all_rules:     edit_rules_link("by name",  :all_rules)
    }
    recently_edited_rules_link button_hash
    nest_rules_link button_hash
    button_hash
  end

  def nest_rules_link button_hash
    return # FIXME: remove when reinstating edit_nest_rules
    return unless nested_fields.present?
    button_hash[:separator] = separator
    button_hash[:edit_nest_rules] = edit_nest_rules_link "nests"
  end

  def recently_edited_rules_link button_hash
    return unless recently_edited_settings?
    button_hash[:recent_rules] = edit_rules_link "recent", :recent_rules
  end

  def edit_rules_link text, rule_view
    subject.link_to_view :edit_rules, text,
                         path: { rule_view: rule_view }
  end

  def edit_nest_rules_link text
    subject.link_to_view :edit_nest_rules, text,
                         path: { rule_view: :field_related_rules }
  end
end
