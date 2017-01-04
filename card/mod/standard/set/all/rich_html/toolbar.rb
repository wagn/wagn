format :html do
  def toolbar_pinned?
    (tp = Card[:toolbar_pinned]) && tp.content == "true"
  end

  view :toolbar do |args|
    tool_navbar do
      [
        expanded_close_link,
        toolbar_split_buttons(args),
        toolbar_simple_buttons(args)
      ]
    end
  end

  def default_toolbar_args args
    args[:nested_fields] = nested_fields
    args[:active_toolbar_button] ||= active_toolbar_button @slot_view, args
  end

  def expanded_close_link
    close_link class: "hidden-xs navbar-right"
  end

  def collapsed_close_link
    close_link class: "pull-right visible-xs"
  end

  def tool_navbar
    navbar "toolbar-#{card.cardname.safe_key}-#{voo.home_view}",
           toggle_align: :left, class: "slotter toolbar",
           navbar_type: "inverse",
           collapsed_content: collapsed_close_link do
      yield
    end
  end

  def toolbar_split_buttons args
    wrap_with :form, class: "navbar-form navbar-left" do
      [
        (account_split_button(args) if card.accountable?),
        activity_split_button(args),
        rules_split_button(args),
        edit_split_button(args)
      ]
    end
  end

  def toolbar_simple_buttons args
    wrap_with :form, class: "navbar-form navbar-right" do
      wrap_with :div, class: "form-group" do
        _optional_render :toolbar_buttons, args, :show
      end
    end
  end

  # TODO: decentralize and let views choose which menu they are in.
  def active_toolbar_button active_view, args
    case active_view
    when :follow, :editors, :history    then "activity"
    when :edit_rules, :edit_nest_rules  then "rules"
    when :edit, :edit_name, :edit_type,
         :edit_structure, :edit_nests   then "edit"
    when :related
      active_related_toolbar_button args[:related_card]
    end
  end

  def active_related_toolbar_button related_card
    return unless (codename = related_codename related_card)
    case codename
    when :discussion, :editors                        then "engage"
    when :account, :roles, :edited, :created, :follow then "account"
    when :structure                                   then "edit"
    else                                                   "rules"
    end
  end

  TOOLBAR_TITLE = {
    edit: "content",             edit_name: "name",      edit_type: "type",
    edit_structure: "structure", edit_nests: "nests",    history: "history",
    common_rules: "common",      recent_rules: "recent", grouped_rules: "all",
    edit_nest_rules: "nests"
  }.freeze

  def toolbar_view_title view
    if view == :edit_rules
      current_set_card.name
    else
      TOOLBAR_TITLE[view]
    end
  end

  def activity_split_button args
    toolbar_split_button "activity", { view: :history }, args do
      {
        history: (_render_history_link if card.history?),
        discuss: link_to_related(:discussion, "discuss"),
        follow:  _render_follow_link(args),
        editors: link_to_related(:editors, "editors")
      }
    end
  end

  def rules_split_button args
    button_hash = {
      common_rules:  edit_rules_link("common",   :common_rules),
      grouped_rules: edit_rules_link("by group", :grouped_rules),
      all_rules:     edit_rules_link("by name",  :all_rules)
    }
    recently_edited_rules_link button_hash
    nest_rules_link button_hash, args[:nested_fields]
    toolbar_split_button("rules", { view: :edit_rules }, args) { button_hash }
  end

  def nest_rules_link button_hash, nested_fields
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
                 path: { slot: { rule_view: :field_related_rules } }
  end

  def edit_rules_link text, rule_view
    link_to_view :edit_rules, text,
                 path: { slot: { rule_view: rule_view } }
  end

  def edit_split_button args
    toolbar_split_button "edit", { view: :edit }, args do
      {
        edit:       _render_edit_link(args),
        edit_nests: (_render_edit_nests_link if nests_editable?(args)),
        structure:  (_render_edit_structure_link if structure_editable?),
        edit_name:  _render_edit_name_link,
        edit_type:  _render_edit_type_link
      }
    end
  end

  def nests_editable? args
    !card.structure && args[:nested_fields].present?
  end

  def account_split_button args
    toolbar_split_button "account", { related: :account.cardname.key }, args do
      {
        account: link_to_related(:account, "details", path: { view: :edit }),
        roles:   link_to_related(:roles,   "roles"),
        created: link_to_related(:created, "created"),
        edited:  link_to_related(:edited,  "edited"),
        follow:  link_to_related(:follow,  "follow")
      }
    end
  end

  def toolbar_split_button name, button_path_opts, args
    status = args[:active_toolbar_button] == name ? "active" : ""
    button_link = button_link name, path: button_path_opts, class: status
    button_args = args.merge active_item: active_toolbar_item(args)
    split_button(button_link, button_args) { yield }
  end

  def active_toolbar_item args
    return @slot_view unless @slot_view == :related
    return args[:rule_view].to_sym if args[:rule_view]
    return @slot_view unless (codename = related_codename args[:related_card])
    codename.to_sym
  end

  def related_codename related_card
    return nil unless related_card
    tag_card = Card.quick_fetch related_card.cardname.right
    tag_card && tag_card.codename
  end

  def close_link args
    path_opts = args[:subslot] ? { slot: { subframe: true } } : {}

    link = link_to_view :home, glyphicon("remove"),
                        path: path_opts, title: "cancel",
                        class: "btn-toolbar-control btn btn-primary"
    css_class = ["nav navbar-nav", args[:class]].compact.join "\n"

    wrap_with :div, class: css_class do
      [toolbar_pin_button, link]
    end
  end

  def toolbar_pin_button
    button_tag glyphicon("pushpin"),
               situation: :primary, remote: true,
               title: "#{'un' if toolbar_pinned?}pin",
               class: "btn-toolbar-control toolbar-pin " \
                      "#{'in' unless toolbar_pinned?}active"
  end

  view :toolbar_buttons do |args|
    show_or_hide_delete = card.ok?(:delete) ? :show : :hide
    wrap_with(:div, class: "btn-group") do
      [
        _optional_render(:delete_button,  args, show_or_hide_delete),
        _optional_render(:refresh_button, args, :show),
        _optional_render(:related_button, args, :show)
      ]
    end
  end

  view :related_button do |_args|
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
      toolbar_view_link viewname
    end
  end

  def toolbar_view_link view
    link_to_view view, voo.title
  end

  def recently_edited_settings?
    (rs = Card[:recent_settings]) && rs.item_names.present?
  end
end
