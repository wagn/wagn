include Card::Set::Type::Css

format :html do
  view :core, :mod=>Css::HtmlFormat
  view :editor, :mod=>PlainText::HtmlFormat
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


