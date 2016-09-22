format :html do
  view :closed_rule, tags: :unknown_ok do
    # these are helpful for handling non-rule rstar cards until we have real
    # rule sets
    return "not a rule" unless card.is_rule?

    rule_card = find_current_rule_card
    rule_content = closed_rule_content rule_card
    known_or_missing = known_or_missing_rule rule_card

    cells = [
      ["rule-setting", link_to_open_rule],
      ["rule-content", rule_content_container(rule_content)],
      ["rule-set", (rule_card ? rule_card.trunk.label : "")]
    ].map do |css_class, cell_content|
      wrap_rule_cell css_class, cell_content, known_or_missing
    end
    %(<tr class="card-slot closed-rule">#{cells.join "\n"}</tr>)
  end

  def wrap_rule_cell css_class, cell_content, known_or_missing
    %(
      <td class="rule-cell #{css_class} #{known_or_missing}">
        #{cell_content}
      </td>
    )
  end

  def known_or_missing_rule rule_card
    rule_card && !rule_card.new_card? ? "known-rule" : "missing-rule"
  end

  def rule_content_container rule_content
    %(
      <div class="rule-content-container">
        <span class="closed-content content">#{rule_content}</span>
      </div>
    )
  end

  def link_to_open_rule
    setting_title = card.cardname.tag.tr "*", ""
    link_to_view :open_rule, setting_title, class: "edit-rule-link slotter"
  end

  def closed_rule_content rule_card
    if rule_card
      subformat(rule_card)._render_closed_content(
        set_context: card.cardname.trunk_name
      )
    else
      ""
    end
  end

  view :open_rule, tags: :unknown_ok do |args|
    return "not a rule" unless card.is_rule?
    setting_name = args[:setting_name]
    current_rule = args[:current_rule]

    rule_view = open_rule_body_view
    rule_view_args = { rule_context: card, set_context: card.rule_set_name }
    body = subformat(current_rule)._render rule_view, rule_view_args

    <<-HTML
      <tr class="card-slot open-rule #{rule_view.to_s.sub '_', '-'}">
        <td class="rule-cell" colspan="3">
          <div class="rule-setting">
            #{open_rule_setting_links setting_name}
          </div>
          <div class="alert alert-info rule-instruction">
            #{open_rule_instruction setting_name}
          </div>
          <div class="card-body">
            #{body}
          </div>
        </td>
      </tr>
    HTML
  end

  def open_rule_setting_links setting_name
    setting_title = setting_name.tr "*", ""
    closed_rule_link = link_to_view :closed_rule, setting_title,
                                    class: "close-rule-link slotter"
    all_rules_link = link_to_card setting_name, "all #{setting_title} rules",
                                  class: "setting-link", target: "wagn_setting"
    closed_rule_link + all_rules_link
  end

  def open_rule_instruction setting_name
    process_content "{{#{setting_name}+*right+*help|content}}"
  end

  def open_rule_body_view
    return :show_rule if params[:success] && !params[:reload]
    card_action = card.new_card? ? :create : :update
    return :show_rule unless card.ok? card_action
    :edit_rule
  end

  def reload_current_rule current_rule
    return current_rule unless (card_args = params[:card])
    if card_args[:name] && card_args[:name].to_name.key != current_rule.key
      Card.new card_args
    else
      current_rule = current_rule.refresh
      current_rule.assign_attributes card_args
      current_rule.include_set_modules
    end
  end

  def default_open_rule_args args
    current_rule = find_current_rule_card || begin
      Card.new name: "#{Card[:all].name}+#{card.rule_user_setting_name}"
    end
    current_rule = reload_current_rule current_rule
    args.reverse_merge! current_rule: current_rule,
                        setting_name: card.rule_setting_name
  end

  view :show_rule, tags: :unknown_ok do |args|
    return "not a rule" unless card.is_rule?

    if !card.new_card?
      set = card.rule_set
      args[:item] ||= :link
      %(
        <div class="rule-set">
        <label>Applies to</label> #{link_to_card set.cardname, set.label}:
        </div>
        #{_render_core args}
      )
    else
      "No Current Rule"
    end
  end

  view :edit_rule, tags: :unknown_ok do |args|
    return "not a rule" unless card.is_rule?
    form_args = {
      url: path(action: :update, mark_type: :name),
      html: { class: "card-form card-rule-form" }
    }
    if args[:remote]
      form_args[:remote] = true
      form_args[:html][:class] += " slotter"
    end

    form_for card, form_args do |form|
      @form = form
      %(
        #{hidden_success_formgroup args[:success]}
        #{editor args}
        #{edit_buttons args}
      )
    end
  end

  view :edit_single_rule do |args|
    %(<div class="edit-single-rule panel-body">#{render_edit_rule args}</div>)
  end

  def default_edit_rule_args args
    args[:remote] ||= true
    args[:rule_context] ||= card
    args[:set_context] ||= card.rule_set_name
    args[:set_selected] = params[:type_reload] ? card.rule_set_name : false
    args[:set_options], args[:fallback_set] = args[:rule_context].set_options

    args[:success] ||= {}
    args[:success].reverse_merge!(
      card: args[:rule_context],
      id:   args[:rule_context].cardname.url_key,
      view: "open_rule",
      item: "view_rule"
    )
    edit_rule_button_args args
  end

  def edit_rule_button_args args
    args[:delete_button] ||= delete_button args
    args[:cancel_button] ||=
      begin
        cancel_view = card.new_card? ? :closed_rule : :open_rule
        cancel_button class: "rule-cancel-button",
                      href: path(view: cancel_view, success: false)
      end
  end

  def default_edit_single_rule_args args
    args[:remote] ||= false
    args[:success] ||= {
      card: args[:parent] || card,
      id: (args[:parent] && args[:parent].cardname.url_key) ||
          card.cardname.url_key,
      view: :open,
      item: nil
    }
    default_edit_rule_args args
    edit_single_rule_button_args args
  end

  def edit_single_rule_button_args args
    args[:delete_button] = delete_button args, ".card-slot.related-view"

    args[:cancel_button] =
      link_to_card args[:success][:id], "Cancel",
                   class: "rule-cancel-button btn btn-default",
                   path: { view: args[:success][:view] }
  end

  def delete_button args, slot_selector=nil
    return if card.new_card?
    b_args = {
      remote: true, class: "rule-delete-button slotter", type: "button"
    }
    b_args["data-slot-selector"] = slot_selector if slot_selector
    b_args[:href] = path action: :delete, success: args[:success]
    if (fset = args[:fallback_set]) && (fcard = Card.fetch(fset))
      b_args["data-confirm"] =
        "Deleting will revert to #{card.rule_setting_name} rule for " \
        "#{fcard.label}"
    end
    %(<span class="rule-delete-section">#{button_tag 'Delete', b_args}</span>)
  end

  # used keys for args:
  # :success,  :set_selected, :set_options, :rule_context
  def editor args
    content = content_field(form, args.merge(skip_rev_id: true))
    wrap_with(:div, class: "card-editor") do
      [
        (type_formgroup(args) if card.right.rule_type_editable),
        formgroup("rule", content, editor: "content"),
        set_selection(args)
      ]
    end
  end

  def type_formgroup args
    content = type_field(
      href: path(name: args[:success][:card].name,
                 view: args[:success][:view],
                 type_reload: true),
      class: "type-field rule-type-field live-type-field",
      "data-remote" => true
    )
    formgroup "type", content, editor: "type"
  end

  def hidden_success_formgroup args
    %(
      #{hidden_field_tag 'success[id]', args[:id] || args[:card].name}
      #{hidden_field_tag 'success[view]', args[:view]}
      #{hidden_field_tag 'success[item]', args[:item]}
    )
  end

  def set_selection args
    wrap_with(:div, class: "row") do
      [
        set_formgroup(args),
        related_set_formgroup(args)
      ]
    end
  end

  def set_formgroup args
    tag = args[:rule_context].rule_user_setting_name
    narrower_rules = []
    option_list "set" do
      args[:set_options].map do |set_name, state|
        set_radio_button set_name, tag, state, narrower_rules,
                         checked: checked_set_button?(set_name, args)
      end
    end
  end

  def set_radio_button set_name, tag, state, narrower_rules, opts
    button = radio_button :name, "#{set_name}+#{tag}",
                          checked: opts[:checked],
                          warning: narrower_rule_warning(narrower_rules)
    label = Card.fetch(set_name).label
    if state.in? [:current, :overwritten]
      narrower_rules << label
      narrower_rules.last[0] = narrower_rules.last[0].downcase
    end
    button + set_label(card, set_name, label, state)
  end

  def checked_set_button? set_name, args
    (args[:set_selected] == set_name) ||
      (current_set_key && args[:set_options].length == 1)
  end

  def current_set_key
    card.new_card? ? Card[:all].cardname.key : card.rule_set_key
  end

  def related_set_formgroup args
    related_sets = args[:set_context] &&
                   Card.fetch(args[:set_context]).prototype.related_sets
    return "" unless related_sets && related_sets.size > 0
    tag = args[:rule_context].rule_user_setting_name
    option_list "related set" do
      related_sets.map do |set_name, label|
        rule_name = "#{set_name}+#{tag}"
        rule_card = Card.fetch rule_name, skip_modules: true
        state = (rule_card && :exists)
        radio_button(:name, rule_name) +
          set_label(card, set_name, label, state)
      end
    end
  end

  def set_label card, set_name, label, state
    label_class = "set-label"
    label_body = link_to_card set_name, label, target: "wagn_set"
    info =
      case state
      when :current
        label_class += " current-set_label"
        "(current)"
      when :overwritten, :exists
        link_to_card "#{set_name}+#{card.rule_user_setting_name}", "(#{state})"
      end
    label_body += " <em>#{info}</em" if info
    %(<label class="#{label_class}">#{label_body}</label>).html_safe
  end

  def narrower_rule_warning narrower_rules
    return unless narrower_rules.present?
    plural = narrower_rules.size > 1 ? "s" : ""
    "This rule will not have any effect on this card unless you delete " \
    "the narrower rule#{plural} for #{narrower_rules.to_sentence}."
  end

  def option_list title
    list = wrap_each_with(:li, class: "radio") { yield }
    formgroup title, "<ul>#{list}</ul>", editor: "set", class: "col-xs-6"
  end

  def edit_buttons  args
    wrap_with(:div, class: "button-area") do
      [
        args[:delete_button],
        button_tag("Submit", class: "rule-submit-button", situation: "primary"),
        args[:cancel_button]
      ]
    end
  end

  # view :edit_rule2 do |args|
  #
  #   card_form :update do
  #     [
  #       _optional_render(:type_formgroup,    args),
  #       _optional_render(:content_formgroup, args),
  #       _optional_render(:set_formgroup,     args),
  #       _optional_render(:button_formgroup,  args)
  #     ]
  #   end
  # end

  private

  def find_current_rule_card
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
