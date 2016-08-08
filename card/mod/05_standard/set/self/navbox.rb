
format :html do
  view :raw do |_args|
    input_args = { class: "navbox form-control" }
    @@placeholder ||= begin
      (p = Card["#{Card[:navbox].name}+*placeholder"]) && p.raw_content
    end
    input_args[:placeholder] = @@placeholder if @@placeholder

    content_tag :div, class: "form-group" do
      text_field_tag :_keyword, "", input_args
    end
  end

  view :navbar_left do |args|
    _render_core args.merge(navbar_class: "navbar-form navbar-left")
  end

  view :navbar_right do |args|
    _render_core args.merge(navbar_class: "navbar-form navbar-right")
  end

  view :core do |args|
    tag_args = { method: "get", role: "search", class: "nodblclick navbox-form #{args[:navbar_class]}" }
    form_tag Card.path_setting("/:search"), tag_args do
      _render_raw args
    end
  end
end
