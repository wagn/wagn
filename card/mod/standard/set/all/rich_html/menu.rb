format :html do
  view :menu, denial: :blank, tags: :unknown_ok, when:{} do |args|
    return "" if card.unknown?
    wrap_with :div, class: "menu-slot nodblclick" do
      [
        _optional_render(:horizontal_menu, args, :hide),
        _render_menu_link(args),
        _render_modal_slot(args.merge(modal_id: card.cardname.safe_key))
      ]
    end
  end

  view :menu_link do |args|
    css_class =
      show_view?(:horizontal_menu, :hide) ? "visible-xs" : "show-on-hover"

    wrap_with :div, class: "vertical-card-menu card-menu #{css_class}" do
      content_tag :div, class: "btn-group slotter card-slot pull-right" do
        link_to_view(:vertical_menu, menu_icon, path: menu_path_opts).html_safe
      end
    end
  end

  def menu_path_opts
    opts = { slot: { home_view: voo.home_view } }
    opts[:is_main] = true if main?
    opts
  end

  def menu_icon
    glyphicon "cog"
  end

  view :vertical_menu, tags: :unknown_ok do
    wrap_with :ul, class: "btn-group pull-right slotter" do
      [vertical_menu_toggle, vertical_menu_item_list]
    end
  end

  def vertical_menu_toggle
    content_tag :span, "<a href='#'>#{menu_icon}</a>".html_safe,
                class: "open-menu dropdown-toggle",
                "data-toggle" => "dropdown",
                "aria-expanded" => "false"
  end

  def vertical_menu_item_list
    content_tag :ul, class: "dropdown-menu", role: "menu" do
      menu_item_list.map do |item|
        "<li>#{item}</li>"
      end.join("\n").html_safe
    end
  end


  view :horizontal_menu do |args|
    content_tag :div, class: "btn-group slotter pull-right card-menu "\
                             "horizontal-card-menu hidden-xs" do
      menu_item_list(class: "btn btn-default").join("\n").html_safe
    end
  end

  def menu_item_list link_opts={}
    [:edit, :discuss, :follow, :page, :rules, :account, :more].map do |item|
      next unless send "show_menu_item_#{item}?"
      send "menu_#{item}_link", link_opts
    end.compact
  end

  def menu_edit_link opts
    menu_item "edit", "edit", opts.merge(view: :edit)
  end

  def menu_discuss_link opts
    menu_item "discuss", "comment", opts.merge(related: Card[:discussion].key)
  end

  def menu_follow_link opts
    _render_follow_link(icon: true, link_opts: opts)
  end

  def menu_page_link opts
    menu_item "page", "new-window", opts.merge(card: card)
  end

  def menu_rules_link opts
    menu_item "rules", "wrench", opts.merge(view: :options)
  end

  def menu_account_link opts
    menu_item "account", "user", opts.merge(
      view: :related,
      path: { related: { name: "+*account", view: :edit } }
    )
  end

  def menu_more_link opts
    view = voo.home_view || :open
    menu_item "", "option-horizontal", opts.merge(
      path: { view: view, slot: { show: :toolbar } }
    )
  end

  def menu_item text, icon, opts={}
    link_text = "#{glyphicon(icon)}<span class='menu-item-label'>#{text}</span>"
    smart_link_to link_text.html_safe, opts
  end

  def show_menu_item_discuss?
    discussion_card = menu_discussion_card
    return unless discussion_card
    permission_task = discussion_card.new_card? ? :comment : :read
    discussion_card.ok? permission_task
  end

  def show_menu_item_page?
    card.name.present? && !main?
  end

  def show_menu_item_rules?
    card.virtual?
  end

  def show_menu_item_edit?
    return unless card.real?
    card.ok?(:update) || structure_editable?
  end

  def show_menu_item_account?
    return unless card.real?
    card.account && card.ok?(:update)
  end

  def show_menu_item_follow?
    return unless card.real?
    show_follow?
  end

  def show_menu_item_more?
    card.real?
  end

  def menu_discussion_card
    return if card.new_card?
    disc_tagname = Card.quick_fetch(:discussion).cardname
    return if card.junction? && card.cardname.tag_name.key == disc_tagname.key
    card.fetch trait: :discussion, skip_modules: true, new: {}
  end
end
