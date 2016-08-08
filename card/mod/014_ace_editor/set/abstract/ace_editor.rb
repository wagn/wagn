format :html do
  def default_editor_args args
    args[:ace_mode] ||= "html"
  end

  view :editor do |args|
    text_area :content, rows: 5,
                        class: "card-content ace-editor-textarea",
                        "data-ace-mode" => args[:ace_mode]
  end
end
