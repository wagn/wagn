format :html do
  def ace_editor_input
    text_area :content, rows: 5,
                        class: "card-content ace-editor-textarea",
                        "data-ace-mode" => ace_mode
  end

  def ace_mode
    :html
  end
end
