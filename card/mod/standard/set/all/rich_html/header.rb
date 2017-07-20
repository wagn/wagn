format :html do
  view :header do
    voo.hide :toggle, :toolbar
    main_header + _optional_render_toolbar
  end

  def main_header
    wrap_with :div, class: classy("d0-card-header") do
      wrap_with :div, class: classy("d0-card-header-title") do
        header_title_elements
      end
    end
  end

  def header_title_elements
    [_optional_render_toggle, _optional_render_title]
  end

  view :subheader do
    wrap_with :div, class: "card-subheader navbar-inverse btn-primary active" do
      [
        _render_title,
        (autosaved_draft_link(class: "pull-right") if show_draft_link?)
      ]
    end
    # toolbar_view_title(@slot_view) || _render_title(args)
  end

  def show_draft_link?
    card.drafts.present? && @slot_view == :edit
  end

  view :toggle do
    verb, adjective, direction = toggle_verb_adjective_direction
    link_to_view adjective, icon_tag(direction),
                 title: "#{verb} #{card.name}",
                 class: "#{verb}-icon toggler slotter nodblclick"
  end

  def toggle_verb_adjective_direction
    if @toggle_mode == :close
      %w[open open expand_more]
    else
      %w[close closed expand_less]
    end
  end

  view :navbar_links do
    wrap_with :ul, class: "navbar-nav" do
      item_links.map do |link|
        wrap_with(:li, class: "nav-item") { link }
      end.join "\n"
    end
  end

  def show_follow?
    Auth.signed_in? && !card.new_card? && card.followable?
  end

  def structure_editable?
    card.structure && card.template.ok?(:update)
  end
end
