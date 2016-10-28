format :html do
  def toolbar_pinned?
    (tp = Card[:toolbar_pinned]) && tp.content == "true"
  end

  view :toolbar do |args|
    collapsed = close_link(args.merge(class: "pull-right visible-xs"))
    navbar "toolbar-#{card.cardname.safe_key}-#{args[:home_view]}",
           toggle_align: :left, class: "slotter toolbar",
           navbar_type: "inverse",
           collapsed_content: collapsed do
      [
        close_link(args.merge(class: "hidden-xs navbar-right")),
        (wrap_with(:form, class: "navbar-form navbar-left") do
          [
            (account_split_button(args) if card.accountable?),
            activity_split_button(args),
            rules_split_button(args),
            edit_split_button(args)
          ]
        end),
        (wrap_with(:form, class: "navbar-form navbar-right") do
          content_tag :div, class: "form-group" do
            _optional_render(:toolbar_buttons, args, :show)
          end
        end)
      ]
    end
  end

  def default_toolbar_args args
    args[:nested_fields] = nested_fields
    args[:active_toolbar_button] ||= active_toolbar_button @slot_view, args
  end

  def active_toolbar_button active_view, args
    case active_view
    when :follow, :editors, :history
      "activity"
    when :edit_rules, :edit_nest_rules
      "rules"
    when :edit, :edit_name, :edit_type, :edit_structure, :edit_nests
      "edit"
    when :related
      if args[:related_card] && (tag = args[:related_card].tag)
        case tag.codename
        when "discussion", "editors"
          "engage"
        when "account", "roles", "edited", "created", "follow"
          "account"
        when "structure"
          "edit"
        else
          "rules"
        end
      end
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
    discuss = smart_link_to "discuss",  related: Card[:discussion].key
    editors = smart_link_to "editors",  related: Card[:editors].key
    toolbar_split_button "activity", { view: :history }, args do
      {
        history:    (_render_history_link if card.history?),
        discuss: discuss,
        follow:  _render_follow_link(args),
        editors: editors
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
    return unless nested_fields.present?
    button_hash[:separator] = separator
    button_hash[:edit_nest_rules] = edit_nest_rules_link "nests"
  end

  def recently_edited_rules_link button_hash
    return unless recently_edited_settings?
    button_hash[:recent_rules] = edit_rules_link "recent", :recent_rules
  end

  def edit_nest_rules_link text
    smart_link_to text, view: :edit_nest_rules,
                        path: { slot: { rule_view: :field_related_rules } }
  end

  def edit_rules_link text, rule_view
    smart_link_to text, view: :edit_rules,
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
    details = "#{card.name}+#{Card[:account].key}"
    toolbar_split_button "account", { related: Card[:account].key }, args do
      {
        account: smart_link_to(
          "details", view: :related,
                     paths: { related: { name: details, view: :edit } }
        ),
        roles:   smart_link_to("roles", related: Card[:roles].key),
        created: smart_link_to("created", related: Card[:created].key),
        edited:  smart_link_to("edited", related: Card[:edited].key),
        follow:  smart_link_to("follow", related: Card[:follow].key)
      }
    end
  end

  def toolbar_split_button name, button_path_opts, args
    status = args[:active_toolbar_button] == name ? "active" : ""
    button = button_link name, path: button_path_opts, class: status
    active_item =
      if @slot_view == :related
        if args[:rule_view]
          args[:rule_view].to_sym
        elsif args[:related_card] && (r = args[:related_card].right) &&
              (cn = r.codename)
          cn.to_sym
        end
      else
        @slot_view
      end
    split_button button, args.merge(active_item: active_item) do
      yield
    end
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
        ["mates",          "bed",          "*mates"],
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

    # if (cardname = opts.delete(:page))
    #   link_to_card cardname, link_text, class: klass
    # elsif (viewname = tag_args.delete(:view))
    #   _opts = opts[:path] || { slot: { show: :toolbar } }
    #   link_to_view viewname, link_text, path: path_opts, format_opts
    # else
    #   path_opts = opts.delete(:path) || {}
    #   path_opts[:action] = opts.delete(:action) if opts[:action]
    #   link_to path_opts, link_text, opts[:format]
    # end
  end

  def toolbar_button_text text, symbol, hide
    icon = glyphicon symbol
    hide ||= "hidden-xs hidden-sm hidden-md hidden-lg"
    css_classes = "menu-item-label #{hide}"
    rich_text = content_tag :span, text.html_safe, class: css_classes
    icon + rich_text
  end

  def autosaved_draft_link
    link_to_view :edit, "autosaved draft",
                 path: { edit_draft: true, slot: { show: :toolbar } },
                 class: "navbar-link slotter pull-right"
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
