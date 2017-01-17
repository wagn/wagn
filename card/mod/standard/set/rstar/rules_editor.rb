format :html do
  def current_rule force_reload=true
    @current_rule = nil if force_reload
    @current_rule ||= begin
      rule = determine_current_rule
      reload_rule rule
    end
  end

  def determine_current_rule
    existing = find_existing_rule_card
    return existing if existing
    Card.new name: "#{Card[:all].name}+#{card.rule_user_setting_name}"
  end

  def open_rule_wrap rule_view
    rule_view_class = rule_view.to_s.tr '_', '-'
    wrap_with :tr, class: "card-slot open-rule #{rule_view_class}" do
      wrap_with(:td, class: "rule-cell", colspan: 3) { yield }
    end
  end

  view :open_rule, cache: :never, tags: :unknown_ok do
    return "not a rule" unless card.is_rule?
    rule_view = open_rule_body_view
    open_rule_wrap(rule_view) do
      [open_rule_instruction,
       open_rule_setting_links,
       open_rule_body(rule_view)]
    end
  end

  def open_rule_body rule_view
    wrap_with :div, class: "card-body" do
      nest current_rule, view: rule_view, rule_context: card
    end
  end

  def open_rule_body_view
    return :show_rule if params[:success] && !params[:type_reload]
    card_action = card.new_card? ? :create : :update
    card.ok?(card_action) ? :edit_rule : :show_rule
  end

  view :show_rule, cache: :never, tags: :unknown_ok do
    return "not a rule" unless card.is_rule?
    return "No Current Rule" if card.new_card?

    voo.items[:view] ||= :link
    show_rule_set(card.rule_set) + _render_core
  end

  def show_rule_set set
    wrap_with :div, class: "rule-set" do
      %(<label>Applies to</label> #{link_to_card set.cardname, set.label}:)
    end
  end

  view :closed_rule, cache: :never, tags: :unknown_ok do
    return "not a rule" unless card.is_rule?
    rule_card = find_existing_rule_card
    wrap_closed_rule rule_card do
      [:setting, :content, :set].map do |cell|
        send "closed_rule_#{cell}_cell", rule_card
      end
    end
  end

  def closed_rule_setting_cell _rule_card
    wrap_rule_cell "rule-setting" do
      link_to_open_rule
    end
  end

  def closed_rule_content_cell rule_card
    wrap_rule_cell "rule-content" do
      rule_content_container { closed_rule_content rule_card }
    end
  end

  def closed_rule_set_cell rule_card
    wrap_rule_cell "rule-set" do
      rule_card ? rule_card.trunk.label : ""
    end
  end

  def wrap_closed_rule rule_card
    klass = rule_card && rule_card.real? ? "known-rule" : "missing-rule"
    wrap_with(:tr, class: "card-slot closed-rule #{klass}") { yield }
  end

  def wrap_rule_cell css_class
    wrap_with(:td, class: "rule-cell #{css_class}") { yield }
  end

  def rule_content_container
    wrap_with :div, class: "rule-content-container" do
      wrap_with(:span, class: "closed-content content") { yield }
    end
  end

  def link_to_open_rule
    setting_title = card.cardname.tag.tr "*", ""
    link_to_view :open_rule, setting_title, class: "edit-rule-link slotter"
  end

  def closed_rule_content rule_card
    return "" unless rule_card
    nest rule_card, view: :closed_content,
                    set_context: card.cardname.trunk_name
  end

  def open_rule_setting_links
    wrap_with :div, class: "rule-setting" do
      [link_to_closed_rule, link_to_all_rules]
    end
  end

  def link_to_all_rules
    link_to_card card.rule_setting_name, "all #{card.rule_setting_title} rules",
                 class: "setting-link", target: "wagn_setting"
  end

  def link_to_closed_rule
    link_to_view :closed_rule, card.rule_setting_title,
                 class: "close-rule-link slotter"
  end

  def open_rule_instruction
    wrap_with :div, class: "alert alert-info rule-instruction" do
      process_content "{{#{card.rule_setting_name}+*right+*help|content}}"
    end
  end

  def reload_rule rule
    return rule unless (card_args = params[:card])
    if card_args[:name] && card_args[:name].to_name.key != rule.key
      Card.new card_args
    else
      rule = rule.refresh
      rule.assign_attributes card_args
      rule.include_set_modules
    end
  end

  view :edit_rule, cache: :never, tags: :unknown_ok do |args|
    return "not a rule" unless card.is_rule?
    @rule_context = args[:rule_context] || card
    @edit_rule_success = edit_rule_success
    action_args = { action: :update, no_mark: true }

    card_form action_args, class: "card-rule-form" do |_form|
      [hidden_tags(success: @edit_rule_success),
       editor,
       edit_rule_buttons].join
    end
  end

  def edit_rule_success
    { id:   @rule_context.cardname.url_key,
      view: "open_rule",
      item: "view_rule" }
  end

  def edit_rule_buttons
    wrap_with(:div, class: "button-area") do
      [
        edit_rule_delete_button,
        edit_rule_submit_button,
        edit_rule_cancel_button
      ]
    end
  end

  def edit_rule_delete_button args={}
    return if card.new_card?
    options = { remote: true,
                type: "button",
                class: "rule-delete-button slotter",
                href: path(action: :delete, success: @edit_rule_success) }
    options["data-slot-selector"] = slot_selector if args[:slot_selector]
    delete_button_confirmation_option options, args[:fallback_set]
    wrap_with :span, class: "rule-delete-section" do
      button_tag "Delete", options
    end
  end

  def delete_button_confirmation_option options, fallback_set
    return unless fallback_set && (fallback_set_card = Card.fetch fallback_set)
    setting = card.rule_setting_name
    options["data-confirm"] = "Deleting will revert to #{setting} rule "\
                              "for #{fallback_set_card.label}"
  end

  def edit_rule_submit_button
    submit_button class: "rule-submit-button"
  end

  def edit_rule_cancel_button
    cancel_view = card.new_card? ? :closed_rule : :open_rule
    cancel_button class: "rule-cancel-button",
                  href: path(view: cancel_view, success: false)
  end

  def editor
    wrap_with(:div, class: "card-editor") do
      [rules_type_formgroup,
       rule_content_formgroup,
       rule_set_selection].compact
    end
  end

  def rules_type_formgroup
    return unless card.right.rule_type_editable
    success = @edit_rule_success
    wrap_type_formgroup do
      type_field(
        href: path(mark: success[:id], view: success[:view], type_reload: true),
        class: "type-field rule-type-field live-type-field",
        "data-remote" => true
      )
    end
  end

  def rule_content_formgroup
    formgroup "rule", editor: "content" do
      content_field true
    end
  end

  def rule_set_selection
    wrap_with :div, class: "row" do
      [rule_set_formgroup,
       related_set_formgroup]
    end
  end

  # def default_edit_rule_args args
  #   args[:set_context] ||= card.rule_set_name
  # end

  def rule_set_formgroup
    tag = @rule_context.rule_user_setting_name
    narrower = []
    option_list "set" do
      rule_set_options.map do |set_name, state|
        rule_set_radio_button set_name, tag, state, narrower
      end
    end
  end

  def rule_set_options
    @rule_set_options ||= @rule_context.set_options
  end

  def selected_rule_set
    if @rule_set_options.length == 1 then true
    elsif params[:type_reload]       then card.rule_set_name
    else                                  false
    end
  end

  def rule_set_radio_button set_name, tag, state, narrower
    warning = narrower_rule_warning narrower, state, set_name
    checked = checked_set_button? set_name, selected_rule_set
    rule_radio set_name, state do
      radio_text = "#{set_name}+#{tag}"
      radio_button :name, radio_text, checked: checked, warning: warning
    end
  end

  def narrower_rule_warning narrower_rules, state, set_name
    return unless state.in? [:current, :overwritten]
    narrower_rules << Card.fetch(set_name).uncapitalized_label
    return unless state == :overwritten
    narrower_rule_warning_message narrower_rules
  end

  def narrower_rule_warning_message narrower_rules
    plural = narrower_rules.size > 1 ? "s" : ""
    "This rule will not have any effect on this card unless you delete " \
    "the narrower rule#{plural} for #{narrower_rules.to_sentence}."
  end

  def checked_set_button? set_name, selected
    [set_name, true].include? selected
  end

  def current_set_key
    card.new_card? ? Card.quick_fetch(:all).cardname.key : card.rule_set_key
  end

  def related_set_formgroup
    related_sets = related_sets_in_context
    return "" unless related_sets && !related_sets.empty?
    tag = @rule_context.rule_user_setting_name
    option_list "related set" do
      related_rule_radios related_sets, tag
    end
  end

  def related_sets_in_context
    set_context = @rule_context.rule_set_name
    set_context && Card.fetch(set_context).prototype.related_sets
  end

  def related_rule_radios related_sets, tag
    related_sets.map do |set_name, _label|
      rule_name = "#{set_name}+#{tag}"
      state = Card.exists?(rule_name) ? :exists : nil
      rule_radio set_name, state do
        radio_button :name, rule_name
      end
    end
  end

  def rule_radio set_name, state
    label_classes = ["set-label", ("current-set-label" if state == :current)]
    icon = glyphicon "question-sign", "link-muted"
    wrap_with :label, class: label_classes.compact.join(" ") do
      [yield,
       rule_radio_label(set_name, state),
       link_to_card(set_name, icon, target: "wagn_set")]
    end
  end

  def rule_radio_label set_name, state
    label = Card.fetch(set_name).label
    extra_info = extra_rule_radio_info state, set_name
    label += " <em>#{extra_info}</em>".html_safe if extra_info
    label
  end

  def extra_rule_radio_info state, set_name
    case state
    when :current
      "(current)"
    when :overwritten, :exists
      link_to_card "#{set_name}+#{card.rule_user_setting_name}", "(#{state})"
    end
  end

  def option_list title
    formgroup title, editor: "set", class: "col-xs-6" do
      wrap_with :ul do
        wrap_each_with(:li, class: "radio") { yield }
      end
    end
  end

  view :edit_single_rule, tags: :unknown_ok, cache: :never do
    frame() { render_edit_rule }
  end

  private

  def find_existing_rule_card
    # self.card is a POTENTIAL rule; it quacks like a rule but may or may not
    # exist.
    # This generates a prototypical member of the POTENTIAL rule's set
    # and returns that member's ACTUAL rule for the POTENTIAL rule's setting
    if card.new_card?
      if (setting = card.right)
        card.set_prototype.rule_card setting.codename, user: card.rule_user
      end
    else
      card
    end
  end
end
