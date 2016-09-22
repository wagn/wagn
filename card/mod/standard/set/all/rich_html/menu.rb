format :html do
  view :menu, denial: :blank, tags: :unknown_ok do |args|
    return _render_template_closer if args[:menu_hack] == :template_closer
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
    menu_icon = glyphicon args[:menu_icon]
    path_opts = { slot: { home_view: args[:home_view] } }
    path_opts[:is_main] = true if main?
    css_class =
      if show_view?(:horizontal_menu,
                    args.merge(default_visibility: :hide, optional: true))
        "visible-xs"
      else
        "show-on-hover"
      end
    wrap_with :div, class: "vertical-card-menu card-menu #{css_class}" do
      content_tag :div, class: "btn-group slotter card-slot pull-right" do
        link_to_view(:vertical_menu, menu_icon, path: path_opts).html_safe
      end
    end
  end

  view :vertical_menu, tags: :unknown_ok do |args|
    items = menu_item_list(args).map do |item|
              "<li class='#{args[:item_class]}'>#{item}</li>"
            end.join "\n"
    wrap_with :ul, class: "btn-group pull-right slotter" do
      [
        content_tag(:span,
                    "<a href='#'>#{glyphicon args[:menu_icon]}</a>".html_safe,
                    class: "open-menu dropdown-toggle",
                    "data-toggle" => "dropdown", "aria-expanded" => "false"),
        content_tag(:ul, items.html_safe, class: "dropdown-menu", role: "menu")
      ]
    end
  end

  view :horizontal_menu do |args|
    content_tag :div, class: "btn-group slotter pull-right card-menu "\
                             "horizontal-card-menu hidden-xs" do
      list_opts = args.merge(link_opts: { class: "btn btn-default" })
      menu_item_list(list_opts).join("\n").html_safe
    end
  end

  def menu_item_list args
    menu_items = []
    menu_items << menu_edit_link(args)    if args[:show_menu_item][:edit]
    menu_items << menu_discuss_link(args) if args[:show_menu_item][:discuss]
    menu_items << menu_follow_link(args)  if args[:show_menu_item][:follow]
    menu_items << menu_page_link(args)    if args[:show_menu_item][:page]
    menu_items << menu_rules_link(args)   if args[:show_menu_item][:rules]
    menu_items << menu_account_link(args) if args[:show_menu_item][:account]
    menu_items << menu_more_link(args)    if args[:show_menu_item][:more]
    menu_items
  end

  def menu_edit_link args
    menu_item "edit", "edit", args[:link_opts].merge(view: :edit)
  end

  def menu_discuss_link args
    opts = args[:link_opts].merge related: Card[:discussion].key
    menu_item "discuss", "comment", opts
  end

  def menu_follow_link args
    _render_follow_link(args.merge(icon: true))
  end

  def menu_page_link args
    opts = args[:link_opts].merge card: card
    menu_item "page", "new-window", opts
  end

  def menu_rules_link args
    opts = args[:link_opts].merge view: :options
    menu_item "rules", "wrench", opts
  end

  def menu_account_link args
    opts = args[:link_opts].merge(
      view: :related,
      path: { related: { name: "+*account", view: :edit } }
    )
    menu_item "account", "user", opts
  end

  def menu_more_link args
    opts = args[:link_opts].merge(
      view: (args[:home_view] || :open),
      path: { view: args[:home_view] || :open },
      slot: { show: :toolbar }
    )
    menu_item "", "option-horizontal", opts
  end

  def menu_item text, icon, opts={}
    link_text = "#{glyphicon(icon)}<span class='menu-item-label'>#{text}</span>"
    smart_link_to link_text.html_safe, opts
  end

  def default_menu_link_args args
    args[:menu_icon] ||= "cog"
  end

  def default_vertical_menu_args args
    default_menu_link_args args
    args.merge! show_menu_item: show_menu_items
  end

  def default_horizontal_menu_args args
    args.merge! show_menu_item: show_menu_items
  end

  def show_menu_items
    disc_tagname = Card.quick_fetch(:discussion).cardname
    disc_card =
      unless card.new_card? || card.junction? &&
                               card.cardname.tag_name.key == disc_tagname.key
        Card.fetch "#{card.name}+#{disc_tagname}", skip_modules: true, new: {}
      end

    res = {
      discuss: disc_card &&
               disc_card.ok?(disc_card.new_card? ? :comment : :read),
      page:    card.name.present? && !main?,
      rules:   card.virtual?
    }
    if card.real?
      res.merge!(
        edit:      card.ok?(:update) || structure_editable?,
        account:   card.account && card.ok?(:update),
        follow:    show_follow?,
        more:      true
      )
    end
    res
  end
end
