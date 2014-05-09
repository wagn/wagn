# -*- encoding : utf-8 -*-
require 'sass'

include Factory
include Supplier

store_factory_product :filetype => "css"

def compressed_css input
  begin
    Sass.compile input, :style=>:compressed
  rescue Exception=>e
    raise Card::Oops, "Stylesheet Error:\n#{ e.message }"
  end
end 

deliver do 
   compressed_css Card::Format.new(self)._render_raw
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


