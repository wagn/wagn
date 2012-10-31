module Wagn::Set::Type::LayoutType
  class Wagn::Renderer
    define_view :editor, :type=>:layout_type do |args|
      form.text_area :content, :rows=>30, :class=>'card-content'
    end
  
    define_view :core, :type=>:layout_type do |args|
      h _render_raw
    end
  end

  def clean_html?
    false
  end
end
