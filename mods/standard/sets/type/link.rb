view :editor do |args|
  form.text_field :content, :class=>'card-content'
end

view :core do |args|
  format.link _render_raw, args['link_text'] || card.name
end
