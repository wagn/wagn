class Wagn::Renderer
  define_view(:naked, :type=>'plain_text') do |args|
    process_content(_render_raw).gsub(/\n/, '<br/>')
  end
  
  define_view(:editor, :type=>'plain_text') do |args|
    form.text_area :content, :rows=>3
  end
  
  define_view(:editor, :type=>'phrase') do |args|
    form.text_field :content, :class=>'phrasebox'
  end

  define_view(:editor, :type=>'number') do |args|
    form.text_field :content
  end

  define_view(:editor, :type=>'html') do |args|
    form.text_area :content, :rows=>30
  end

  define_view(:closed_content, :type=>'html') do |args|
    ''
  end
end
