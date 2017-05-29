format :html do
  def tinymce_editor
    text_area :content, rows: 3, class: "tinymce-textarea card-content",
                        id: unique_id
  end
end
