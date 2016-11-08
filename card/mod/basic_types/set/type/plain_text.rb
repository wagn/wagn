format :html do
  view :editor do
    text_area :content,
              rows: 5,
              class: "card-content",
              "data-card-type-code" => card.type_code
  end

  view :core do
    process_content CGI.escapeHTML(_render_raw)
  end
end
