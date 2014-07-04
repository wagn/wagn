# -*- encoding : utf-8 -*-
require 'sass'

include Machine
include MachineInput

store_machine_output :filetype => "css"

def compressed_css input
  begin
    Sass.compile input, :style=>:compressed
  rescue =>e
    raise Card::Oops, "Stylesheet Error:\n#{ e.message }"
  end
end 

machine_input do
   compressed_css format(:format => :css)._render_core
end


format :html do

  view :editor, :mod=>PlainText::HtmlFormat
  
  view :core do |args|
    #fixme - shouldn't we just render SCSS?
    css = compile_scss _render_raw
    highlighted_css = ::CodeRay.scan( css, :css ).div
    process_content highlighted_css
  end
  
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


