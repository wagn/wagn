format :html do
  view :editor do
    text_area :content, rows: 3, class: "tinymce-textarea card-content",
                        id: unique_id
  end
end
