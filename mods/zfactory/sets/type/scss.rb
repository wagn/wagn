# -*- encoding : utf-8 -*-
require 'sass'

include Factory
include Supplier

def compress_css input
  begin
    Sass.compile input, :style=>:compressed
  rescue Exception=>e
    raise Card::Oops, "Stylesheet Error:\n#{ e.message }"
  end
end 

factory_process do |input_card|
  compress_css input_card.content
end

deliver do 
   compess_css content
end


format :html do

  view :editor, :type=>:plain_text
  
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
  rescue Exception=>e
    e
  end
    
end

event :reset_style_for_scss, :after=>:store do
  Right::Style.delete_style_files
end

