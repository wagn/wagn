
format :html do
  view :raw do
    wrap_with :div, class: "form-group" do
      text_field_tag :_keyword, "", class: "navbox form-control",
                                    placeholder: navbar_placeholder
    end
  end

  def navbar_placeholder
    @@placeholder ||= begin
      holder_card = Card["#{Card[:navbox].name}+*placeholder"]
      holder_card ? holder_card.raw_content : ""
    end
  end

  view :navbar_left do
    class_up "navbox-form", "navbar-form navbar-left"
    _render_core
  end

  view :navbar_right do
    class_up "navbox-form", "navbar-form navbar-left"
    _render_core
  end

  view :core do
    form_tag Card.path_setting("/:search"),
             method: "get", role: "search",
             class: classy("navbox-form", "nodblclick") do
      _render_raw
    end
  end
end
