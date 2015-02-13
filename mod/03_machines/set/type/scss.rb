include Type::Css

def diff_args
  {:format=>:text}
end  


format do
  include Css::Format
  
  view :core do |args|
    process_content compile_scss(_render_raw)
  end
  
  def compile_scss scss, style=:expanded
    Sass.compile scss, :style=>style
  rescue =>e
    e
  end
  
end


format( :html ) { include Css::HtmlFormat }
  



