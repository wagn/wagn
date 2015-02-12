include Card::Set::Type::Css

format :html do
  view :core, :mod=>Css::HtmlFormat
  view :editor, :mod=>PlainText::HtmlFormat
  view :content_changes, :mod=>CoffeeScript::HtmlFormat
end
  
def diff_args
  {:format=>:text}
end  

format do
  view :core do |args|
    process_content compile_scss(_render_raw)
  end
  
  def compile_scss scss, style=:expanded
    Sass.compile scss, :style=>style
  rescue =>e
    e
  end
  

end


