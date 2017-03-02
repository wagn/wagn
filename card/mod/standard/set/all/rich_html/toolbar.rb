format :html do

  TOOLBAR_TITLE = {
    edit: "content",             edit_name: "name",      edit_type: "type",
    edit_structure: "structure", edit_nests: "nests",    history: "history",
    common_rules: "common",      recent_rules: "recent", grouped_rules: "all",
    edit_nest_rules: "nests"
  }.freeze

  def toolbar_pinned?
    (tp = Card[:toolbar_pinned]) && tp.content == "true"
  end

  view :toolbar, cache: :never do
    tool_navbar do
      [
        expanded_close_link,
        toolbar_split_buttons,
        collapsed_close_link,
        toolbar_simple_buttons
      ]
    end
  end

  def default_toolbar_args args
    if params[:related]
      @related_card, _opts = related_card_and_options args.clone
    end
    @rule_view = params[:rule_view]
  end

  # def default_toolbar_args args
  #   args[:nested_fields] = nested_fields
  #   args[:active_toolbar_button] ||= active_toolbar_button @slot_view, args
  # end

  def expanded_close_link
    opts = {}
    opts[:no_nav] = true
    close_link "hidden-xs pull-right navbar-text"
  end

  def collapsed_close_link
    opts = {}
    opts[:no_nav] = true
    close_link "pull-right visible-xs navbar-text", opts
  end

  def tool_navbar
    navbar "toolbar-#{card.cardname.safe_key}-#{voo.home_view}",
           toggle_align: :left, class: "slotter toolbar",
           navbar_type: "inverse",
           no_collapse: true do
      yield
    end
  end

  def toolbar_split_buttons
    wrap_with :form, class: "pull-left navbar-text" do
      [
        (account_split_button if card.accountable?),
        activity_split_button,
        rules_split_button,
        edit_split_button
      ]
    end
  end

  def toolbar_simple_buttons
    wrap_with :form, class: "pull-right navbar-text" do
      wrap_with :div do
        _optional_render :toolbar_buttons
      end
    end
  end

  # TODO: decentralize and let views choose which menu they are in.
  # (Also, should only be represented once.  Currently we must configure
  # this relationship twice)
  def active_toolbar_button
    @active_toolbar_button ||=
      case voo.root.ok_view
      when :follow, :editors, :history    then "activity"
      when :edit_rules, :edit_nest_rules  then "rules"
      when :edit, :edit_name, :edit_type,
           :edit_structure, :edit_nests   then "edit"
      when :related                       then active_related_toolbar_button
      end
  end

  def active_related_toolbar_button
    return unless (codename = related_codename @related_card)
    case codename
    when :discussion, :editors                        then "activity"
    when :account, :roles, :edited, :created, :follow then "account"
    when :structure                                   then "edit"
    else                                                   "rules"
    end
  end

  def active_toolbar_item
    @active_toolbar_item ||=
      case
      when @rule_view                   then @rule_view.to_sym
      when voo.root.ok_view != :related then voo.root.ok_view
      when @related_card                then related_codename @related_card
      end
  end

  def toolbar_view_title view
    if view == :edit_rules
      current_set_card.name
    else
      TOOLBAR_TITLE[view]
    end
  end

  def activity_split_button
    toolbar_split_button "activity", view: :history, icon: :time do
      {
        history: (_render_history_link if card.history?),
        discussion: link_to_related(:discussion, "discuss"),
        follow:  _render_follow_link,
        editors: link_to_related(:editors, "editors")
      }
    end
  end

  def rules_split_button
    button_hash = {
      common_rules:  edit_rules_link("common",   :common_rules),
      grouped_rules: edit_rules_link("by group", :grouped_rules),
      all_rules:     edit_rules_link("by name",  :all_rules)
    }
    recently_edited_rules_link button_hash
    nest_rules_link button_hash
    toolbar_split_button("rules", view: :edit_rules, icon: :list) { button_hash }
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

  def edit_nest_rules_link text
    link_to_view :edit_nest_rules, text,
                 path: { rule_view: :field_related_rules }
  end

  def edit_rules_link text, rule_view
    link_to_view :edit_rules, text,
                 path: { rule_view: rule_view }
  end

  def edit_split_button
    toolbar_split_button "edit", view: :edit, icon: :edit do
      {
        edit:       _render_edit_link,
        edit_nests: (_render_edit_nests_link if nests_editable?),
        structure:  (_render_edit_structure_link if structure_editable?),
        edit_name:  _render_edit_name_link,
        edit_type:  _render_edit_type_link
      }
    end
  end

  def nests_editable?
    !card.structure && nested_fields.present?
  end

  def account_split_button
    toolbar_split_button "account", related: :account do
      {
        account: link_to_related(:account, "details", path: { view: :edit }),
        roles:   link_to_related(:roles,   "roles"),
        created: link_to_related(:created, "created"),
        edited:  link_to_related(:edited,  "edited"),
        follow:  link_to_related(:follow,  "follow")
      }
    end
  end

  def toolbar_split_button name, button_link_opts
    status = active_toolbar_button == name ? "active" : ""
    html_class = "visible-md visible-lg pull-right"
    icon = button_link_opts.delete(:icon)
    name_content = "&nbsp;#{name}"
    name = icon ? glyphicon(icon) : ""
    name += content_tag(:span, name_content.html_safe, class: html_class)
    button_link = button_link name, button_link_opts.merge(class: status)
    split_button(button_link, active_toolbar_item) { yield }
  end

  def related_codename related_card
    return nil unless related_card
    tag_card = Card.quick_fetch related_card.cardname.right
    tag_card && tag_card.codename.to_sym
  end

  def close_link extra_class, opts={}
    nav_css_classes = css_classes("nav navbar-nav", extra_class)
    css_classes = opts[:no_nav] ? extra_class : nav_css_classes
    wrap_with :div, class: css_classes do
      [
        toolbar_pin_button,
        link_to_view(voo.home_view, glyphicon("remove"),
                     title: "cancel",
                     class: "btn-toolbar-control btn btn-primary")
      ]
    end
  end

  def toolbar_pin_button
    button_tag glyphicon("pushpin"),
               situation: :primary, remote: true,
               title: "#{'un' if toolbar_pinned?}pin",
               class: "btn-toolbar-control toolbar-pin hidden-xs " \
                      "#{'in' unless toolbar_pinned?}active"
  end

  view :toolbar_buttons, cache: :never do
    related_button = _optional_render(:related_button).html_safe
    wrap_with(:div, class: "btn-group") do
      [
        _optional_render(:delete_button,
                         optional: (card.ok?(:delete) ? :show : :hide)),
        _optional_render(:refresh_button),
        content_tag(:div, related_button, class: "hidden-xs pull-left")
      ]
    end
  end

  view :related_button do
    dropdown_button "", icon: "education", class: "related" do
      [
        ["children",       "baby-formula", "*children"],
        # ["mates",          "bed",          "*mates"],
        # FIXME: optimize and restore
        ["references out", "log-out",      "*refers_to"],
        ["references in",  "log-in",       "*referred_to_by"]
      ].map do |title, icon, tag|
        menu_item " #{title}", icon, related: tag,
                                     path: { slot: { show: :toolbar } }
      end
    end
  end

  view :refresh_button do |_args|
    icon = main? ? "refresh" : "new-window"
    toolbar_button "refresh", icon, card: card,
                                    path: { slot: { show: :toolbar } }
  end

  view :delete_button do |_args|
    confirm = "Are you sure you want to delete #{card.name}?"
    success = main? ? "REDIRECT: *previous" : "TEXT: #{card.name} deleted"
    toolbar_button "delete", "trash",
                   path: { action: :delete, success: success },
                   class: "slotter", remote: true, :'data-confirm' => confirm
  end

  def toolbar_button text, symbol, opts={}
    link_text = toolbar_button_text text, symbol, opts.delete(:hide)
    opts[:class] = [opts[:class], "btn btn-primary"].compact * " "
    opts[:title] ||= text
    smart_link_to link_text, opts
  end

  def toolbar_button_text text, symbol, hide
    icon = glyphicon symbol
    hide ||= "hidden-xs hidden-sm hidden-md hidden-lg"
    css_classes = "menu-item-label #{hide}"
    rich_text = wrap_with :span, text.html_safe, class: css_classes
    icon + rich_text
  end

  def autosaved_draft_link opts={}
    text = opts.delete(:text) || "autosaved draft"
    opts[:path] = { edit_draft: true, slot: { show: :toolbar } }
    add_class opts, "navbar-link slotter"
    link_to_view :edit, text, opts
  end

  {
    edit:           "content",
    edit_name:      "name",
    edit_type:      "type",
    edit_nests:     "nests",
    edit_structure: "structure",
    history:        "history"
  }.each do |viewname, viewtitle|

    view "#{viewname}_link" do
      voo.title ||= viewtitle
      link_to_view viewname, voo.title
    end
  end

  def recently_edited_settings?
    (rs = Card[:recent_settings]) && rs.item_names.present?
  end
end
