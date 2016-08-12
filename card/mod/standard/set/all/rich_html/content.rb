def show_comment_box_in_related?
  false
end

format :html do
  def show view, args
    if show_layout?
      args[:view] = view if view
      @main_opts = args
      render :layout
    else
      view ||= args[:home_view] || :open
      @nest_opts = (args[:items] || {}).clone
      render view, args
    end
  end

  def show_layout?
    !Env.ajax? || params[:layout]
  end

  view :layout, perms: :none do |args|
    output [
      process_content(get_layout_content, content_opts:
        { chunk_list: :references }),
      _render_modal_slot(args)
    ]
  end

  view :content do |args|
    wrap args.reverse_merge(slot_class: "card-content") do
      [
        _optional_render(:menu, args, :hide),
        _render_core(args)
      ]
    end
  end

  view :content_panel do |args|
    wrap args.reverse_merge(slot_class: "card-content panel panel-default") do
      wrap_with :div, class: "panel-body" do
        [
          _optional_render(:menu, args, :hide),
          _render_core(args)
        ].join("\n")
      end
    end
  end

  view :titled, tags: :comment do |args|
    wrap args do
      [
        _optional_render(:menu, args),
        _render_header(args),
        wrap_body(content: true) { _render_core args },
        optional_render(:comment_box, args)
      ]
    end
  end

  view :labeled do |args|
    wrap args do
      [
        _optional_render(:menu, args),
        "<label>#{_render_title args}</label>",
        wrap_body(body_class: "closed-content", content: true) do
          _render_closed_content args
        end
      ]
    end
  end

  view :title do |args|
    title = fancy_title args[:title], args[:title_class]
    title =
      _optional_render(:title_editable, args, :hide) ||
      _optional_render(:title_link, args.merge(title_ready: title), :hide) ||
      title
    add_name_context
    title
  end

  view :title_link do |args|
    title_text = args[:title_ready] || showname(args[:title])
    card_link card.cardname, text: title_text
  end

  view :type_info do
    link_args = { text: card.type_name.to_s, class: "navbar-link" }
    link = card_link card.type_name, link_args
    %(<span class="type-info pull-right">#{link}</span>).html_safe
  end

  view :title_editable do |args|
    links = card.cardname.parts.map do |name|
      card_link name
    end
    res = links.shift
    links.each_with_index do |link, index|
      name = card.cardname.parts[0..index + 1].join "+"
      res += card_link name, text: glyphicon("plus", "header-icon")
      res += link
    end
    res += " "
    res.concat view_link(
      glyphicon("edit", "header-icon"),
      :edit_name,
      class: "slotter", "data-toggle" => "tooltip", title: "edit name"
    )
    res.concat _optional_render(:type_link, args, :show)
  end

  view :open, tags: :comment do |args|
    args[:optional_toggle] ||= main? ? :hide : :show
    frame args.merge(content: true) do
      [
        _render_open_content(args),
        optional_render(:comment_box, args)
      ]
    end
  end

  # view :anchor, perms: :none, tags: :unknown_ok do |args|
  #   %{ <a id="#{card.cardname.url_key}" name="#{card.cardname.url_key}"></a> }
  # end

  view :type do |args|
    klasses = ["cardtype"]
    klass = args[:type_class]
    klasses << klass if klass
    card_link card.type_card.name, class: klasses
  end

  view :closed do |args|
    frame args.reverse_merge(
      content: true,
      body_class: "closed-content",
      toggle_mode: :close,
      optional_toggle: :show,
      optional_toolbar: :hide
    ) do
      _optional_render :closed_content, args
    end
  end

  view :change do |args|
    args[:optional_title_link] = :show
    wrap args do
      [
        _optional_render(:title, args),
        _optional_render(:menu, args, :hide),
        _optional_render(:last_action, args)
      ]
    end
  end

  def current_set_card
    set_name = params[:current_set]
    if card.known? && card.type_id == Card::CardtypeID
      set_name ||= "#{card.name}+*type"
    end
    set_name ||= "#{card.name}+*self"
    Card.fetch(set_name)
  end

  view :related do |args|
    if args[:related_card]
      frame args.merge(optional_toolbar: :show) do
        nest(args[:related_card], args[:related_args])
      end
    end
  end

  def default_related_args args
    rparams = args[:related] || params[:related]
    return unless rparams
    rcard = rparams[:card] || begin
      rcardname = rparams[:name].to_name.to_absolute_name(card.cardname)
      Card.fetch rcardname, new: {}
    end

    subheader = with_name_context(card.name) do
      subformat(rcard)._render_title(args)
    end
    add_name_context card.name
    nest_args = (rparams[:slot] || {}).deep_symbolize_keys.reverse_merge(
      view:            (rparams[:view] || :open),
      optional_header: :hide,
      optional_menu:   :show,
      subheader:       subheader,
      optional_toggle: :hide,
      optional_help:   :show,
      parent:          card,
      subframe:        true,
      subslot:         true
    )
    if rcard.show_comment_box_in_related?
      nest_args[:optional_comment_box] = :show
    end
    args[:related_args] = nest_args
    args[:related_card] = rcard
  end

  view :help, tags: :unknown_ok do |args|
    text = args[:help_text] || begin
      setting = card.new_card? ? [:add_help, { fallback: :help }] : :help
      help_card = card.rule_card(*setting)
      if help_card && help_card.ok?(:read)
        with_nest_mode :normal do
          raw_help_content = _render_raw args.merge(structure: help_card.name)
          process_content raw_help_content, content_opts:
            { chunk_list: :references }
          # render help card with current card's format
          # so current card's context is used in help card nests
        end
      end
    end
    klass = [args[:help_class], "help-text"].compact * " "
    %(<div class="#{klass}">#{raw text}</div>) if text
  end

  view :last_action do
    act = card.last_act
    return unless act
    action = act.action_on card.id
    return unless action
    action_verb =
      case action.action_type
      when :create then "added"
      when :delete then "deleted"
      else
        link_to(
          "edited",
          path(view: :history),
          class: "last-edited", rel: "nofollow"
        )
      end

    %(
      <span class="last-update">
        #{action_verb} #{_render_acted_at} ago by
        #{subformat(card.last_actor)._render_link}
      </span>
    )
  end

  private

  def fancy_title title=nil, title_class=nil
    klasses = ["card-title", title_class].compact * " "
    title = showname(title).to_name.parts.join %(<span class="joint">+</span>)
    raw %(<span class="#{klasses}">#{title}</span>)
  end
end
