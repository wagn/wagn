format :html do
  view :editor do |_args|
    wrap_with(:div, id: unique_id, class: "prosemirror-editor") do
      hidden_field(:content, class: "card-content", value: card.raw_content)
    end
  end
end
