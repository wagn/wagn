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
    args[:nested_fields] = nested_fields(args)
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
    edit: "content", edit_name: "name", edit_type: "type",
    edit_structure: "structure", edit_nests: "nests", history: "history",
    common_rules: "common", recent_rules: "recent", grouped_rules: "all",
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
    discuss = smart_link "discuss",  related: Card[:discussion].key
    editors = smart_link "editors",  related: Card[:editors].key
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
    recent = smart_link "recent",   view: :edit_rules,
                                    slot: { rule_view: :recent_rules }
    common = smart_link "common",   view: :edit_rules,
                                    slot: { rule_view: :common_rules }
    group  = smart_link "by group", view: :edit_rules,
                                    slot: { rule_view: :grouped_rules }
    all    = smart_link "by name",  view: :edit_rules,
                                    slot: { rule_view: :all_rules }
    nests  = smart_link "nests",    view: :edit_nest_rules,
                                    slot: { rule_view: :field_related_rules }
    toolbar_split_button "rules",   { view: :edit_rules }, args do
      {
        common_rules:    common,
        grouped_rules:   group,
        all_rules:       all,
        separator:       (separator if args[:nested_fields].present?),
        recent_rules:    (recent if recently_edited_settings?),
        edit_nest_rules: (nests if args[:nested_fields].present?)
      }
    end
  end

  def edit_split_button args
    toolbar_split_button "edit", { view: :edit }, args do
      {
        edit:       _render_edit_content_link(args),
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
    toolbar_split_button "account", { related: Card[:account].key }, args do
      {
        account: smart_link("details",
                            related: {
                              name: "#{card.name}+#{Card[:account].key}",
                              view: :edit }
                           ),
        roles:   smart_link("roles", related: Card[:roles].key),
        created: smart_link("created", related: Card[:created].key),
        edited:  smart_link("edited", related: Card[:edited].key),
        follow:  smart_link("follow", related: Card[:follow].key)
      }
    end
  end

  def toolbar_split_button name, button_args, args
    button =
      button_link name, button_args,
                  class: ("active" if args[:active_toolbar_button] == name)
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
    link_opts = { title: "cancel",
                  class: "btn-toolbar-control btn btn-primary" }
    link_opts[:path_opts] = { slot: { subframe: true } } if args[:subslot]
    link = view_link glyphicon("remove"), :home, link_opts
    css_class = ["nav navbar-nav", args[:class]].compact.join "\n"
    wrap_with :div, class: css_class do
      [
        toolbar_pin_button,
        link
      ]
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
        _optional_render(:related_button, args, :show),
        _optional_render(:history_button, args, :hide)
      ]
    end
  end

  view :related_button do |_args|
    path_opts = { slot: { show: :toolbar } }
    dropdown_button "", icon: "education", class: "related" do
      [
        menu_item(" children",       "baby-formula",
                  path_opts.merge(related: "*children")),
        menu_item(" mates",          "bed",
                  path_opts.merge(related: "*mates")),
        menu_item(" references out", "log-out",
                  path_opts.merge(related: "*refers_to")),
        menu_item(" references in",  "log-in",
                  path_opts.merge(related: "*referred_to_by"))
      ]
    end
  end
  view :refresh_button do |_args|
    path_opts = { slot: { show: :toolbar }, page: card }
    icon = main? ? "refresh" : "new-window"
    toolbar_button "refresh", icon, "hidden-xs hidden-sm hidden-md hidden-lg",
                   path_opts: path_opts
  end

  view :delete_button do |_args|
    toolbar_button(
      "delete", "trash", "hidden-xs hidden-sm hidden-md hidden-lg",
      action: :delete,
      class: "slotter",
      remote: true,
      path_opts: {
        success: main? ? "REDIRECT: *previous" : "TEXT: #{card.name} deleted"
      },
      :'data-confirm' => "Are you sure you want to delete #{card.name}?"
    )
  end

  def toolbar_button text, symbol, hide=nil, tag_args={}
    hide ||= "hidden-xs hidden-sm hidden-md hidden-lg"
    tag_args[:class] = [tag_args[:class], "btn btn-primary"].compact * " "
    tag_args[:title] ||= text
    link_text =
      glyphicon(symbol) +
      content_tag(:span, text.html_safe, class: "menu-item-label #{hide}")

    if (cardname = tag_args.delete(:page))
      card_link cardname, class: klass, text: link_text
    elsif (viewname = tag_args.delete(:view))
      tag_args[:path_opts] ||= { slot: { show: :toolbar } }
      view_link link_text, viewname, tag_args
    else
      path_opts = tag_args.delete(:path_opts) || {}
      path_opts[:action] = tag_args.delete(:action) if tag_args[:action]
      link_to link_text, path_opts, tag_args
    end
  end

  def autosaved_draft_link
    view_link "autosaved draft", :edit,
              path_opts: { edit_draft: true, slot: { show: :toolbar } },
              class: "navbar-link slotter pull-right"
  end

  def default_edit_content_link_args args
    args[:title] ||= "content"
  end
  view :edit_content_link do |args|
    toolbar_view_link :edit, args
  end

  def default_edit_name_link_args args
    args[:title] ||= "name"
  end
  view :edit_name_link do |args|
    toolbar_view_link :edit_name, args
  end

  def default_edit_type_link_args args
    args[:title] ||= "type"
  end
  view :edit_type_link do |args|
    toolbar_view_link :edit_type, args
  end

  view :edit_structure_link do |_args|
    smart_link "structure", view: :edit_structure
  end

  def default_history_link_args args
    args[:title] ||= "history"
  end
  view :history_link do |args|
    toolbar_view_link :history, args
  end

  def default_edit_nests_link_args args
    args[:title] ||= "nests"
  end
  view :edit_nests_link do |args|
    toolbar_view_link :edit_nests, args
  end

  def toolbar_view_link view, args
    text = args.delete(:title)
    view_link text, view, args
  end

  def recently_edited_settings?
    (rs = Card[:recent_settings]) && rs.item_names.present?
  end
end
