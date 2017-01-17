format :html do
  # TODO: find these a better home.
  def class_up klass, classier, force=false
    key = klass.to_s
    return if !force && class_list[key]
    class_list[key] = classier.to_s
  end

  # don't use in the given block the additional class that
  # was added to `klass`
  def without_upped_class klass
    tmp_class = class_list.delete klass
    result = yield tmp_class
    class_list[klass] = tmp_class
    result
  end

  def class_list
    @class_list ||= {}
  end

  def classy *classes
    classes = Array.wrap(classes).flatten
    [classes, class_list[classes.first]].flatten.compact.join " "
  end

  view :header do
    voo.hide :toggle, :toolbar
    main_header + _optional_render_toolbar
  end

  def main_header
    wrap_with :div, class: classy("card-header") do
      wrap_with :div, class: classy("card-header-title") do
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
    link_to_view adjective, glyphicon(direction),
                 title: "#{verb} #{card.name}",
                 class: "#{verb}-icon toggler slotter nodblclick"
  end

  def toggle_verb_adjective_direction
    if @toggle_mode == :close
      %w(open open expand)
    else
      %w(close closed collapse-down)
    end
  end

  def nav_link_list side
    wrap_with :ul, class: "nav navbar-nav navbar-#{side}" do
      item_links.map do |link|
        wrap_with(:li) { link }
      end.join "\n"
    end
  end

  view :navbar_right do
    nav_link_list :right
  end

  view :navbar_left do
    nav_link_list :left
  end

  def show_follow?
    Auth.signed_in? && !card.new_card? && card.followable?
  end

  def structure_editable?
    card.structure && card.template.ok?(:update)
  end
end
