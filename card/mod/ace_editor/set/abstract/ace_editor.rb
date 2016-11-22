format :html do
  view :editor do |args|
    args[:ace_mode] ||= "html"
    text_area :content, rows: 5,
                        class: "card-content ace-editor-textarea",
                        "data-ace-mode" => args[:ace_mode]
  end
end
