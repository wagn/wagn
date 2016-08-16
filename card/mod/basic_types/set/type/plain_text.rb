format :html do
  view :editor do |_args|
    text_area :content,
              rows: 5,
              class: "card-content",
              "data-card-type-code" => card.type_code
  end

  view :core do |_args|
    process_content_object(CGI.escapeHTML _render_raw)
  end
end
