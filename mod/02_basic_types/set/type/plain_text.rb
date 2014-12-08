format :html do

  view :editor do |args|
    form.text_area :content, :rows=>5, :class=>'card-content', :editor_type=>card.type_name
  end
  
  view :core do |args|
    process_content_object( CGI.escapeHTML _render_raw )
  end
end
