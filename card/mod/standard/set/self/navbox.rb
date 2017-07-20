
format :html do
  view :raw do
    wrap_with :div, class: "form-group w-100" do
      text_field_tag :_keyword, "", class: "_navbox navbox form-control w-100",
                                    placeholder: navbar_placeholder
    end
  end

  def navbar_placeholder
    @@placeholder ||= begin
      holder_card = Card["#{Card[:navbox].name}+*placeholder"]
      holder_card ? holder_card.raw_content : "Search"
    end
  end

  view :navbar do
    class_up "navbox-form", "form-inline w-25"
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
