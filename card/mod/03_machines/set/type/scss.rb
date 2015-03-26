include Type::Css

def diff_args
  {:format=>:text}
end  

format do
  include Css::Format
  
  view :core do |args|
    compile_scss(process_content _render_raw)
  end
  
  def compile_scss scss, style=:expanded
    Sass.compile scss, :style=>style
  rescue =>e
    e
  end
  
end

format( :html ) { include Css::HtmlFormat }  
