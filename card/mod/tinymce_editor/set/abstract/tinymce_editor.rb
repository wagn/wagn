format :html do
  view :editor do |_args|
    text_area :content, rows: 3, class: "tinymce-textarea card-content",
                        id: unique_id
  end
end
