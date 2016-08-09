format :html do
  view :header do |args|
    %(
      <div class="card-header #{args[:header_class]}">
        <div class="card-header-title #{args[:title_class]}">
          #{_optional_render :toggle, args, :hide}
          #{_optional_render :title, args}
        </div>
        #{_optional_render :type_info, args, :hide}
      </div>
      #{_optional_render :toolbar, args, :hide}
    )
  end

  def default_header_args args
    args[:optional_toolbar] ||= :show if @slot_view == :open && toolbar_pinned?
    if show_view?(:toolbar, args.merge(default_visibility: :hide)) && card.type_code != :basic
      args[:optional_type_info] ||= :show
    end
  end

  view :subheader do |args|
    args[:subheader] ||= toolbar_view_title(@slot_view) || _render_title(args)
    %(
      <div class="card-subheader navbar-inverse btn-primary active">
        #{args[:subheader]}
        #{autosaved_draft_link if card.drafts.present? && @slot_view == :edit}
      </div>
    )
  end

  view :toggle do |args|
    verb, adjective, direction = (args[:toggle_mode] == :close ? %w(open open expand) : %w(close closed collapse-down))

    link_to  glyphicon(direction),
             path(view: adjective),
             remote: true,
             title: "#{verb} #{card.name}",
             class: "#{verb}-icon toggler slotter nodblclick"
  end

  view :link_list do |args|
    content_tag :ul, class: args[:class] do
      item_links(args).map do |al|
        content_tag :li, raw(al)
      end.join "\n"
    end
  end

  view :navbar_right do |args|
    render_link_list args.merge(class: "nav navbar-nav navbar-right")
  end

  view :navbar_left do |args|
    render_link_list args.merge(class: "nav navbar-nav navbar-left")
  end

  def show_follow?
    Auth.signed_in? && !card.new_card? && card.followable?
  end

  def structure_editable?
    card.structure && card.template.ok?(:update)
  end
end
