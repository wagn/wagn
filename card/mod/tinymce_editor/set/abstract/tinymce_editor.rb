format :html do
  def tinymce_editor_input
    text_area :content, rows: 3, class: "tinymce-textarea d0-card-content",
                        id: unique_id
  end
end
