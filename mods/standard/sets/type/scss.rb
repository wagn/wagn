include Card::Set::Type::Css
include Machine
include MachineInput

store_machine_output :filetype => "css"

machine_input do 
  compress_css format(:format => :css)._render_core
end


format do
  view :core do |args|
    process_content compile_scss(_render_raw)
  end
  
  def compile_scss scss, style=:expanded
    Sass.compile scss, :style=>style
  rescue Exception=>e
    e
  end 
end


