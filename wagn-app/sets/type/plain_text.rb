view :editor, :type=>'plain_text' do |args|
  form.text_area :content, :rows=>3, :class=>'card-content'
end


format :html do

  view :core, :type=>'plain_text' do |args|
    process_content_object( CGI.escapeHTML _render_raw )
  end
end
