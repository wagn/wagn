class Wagn::Renderer
  define_view :editor, :type=>'layout' do |args|
    form.text_area :content, :rows=>30, :class=>'card-content'
  end
  
  define_view :core, :type=>'layout' do |args|
    h _render_raw
  end
end