# -*- encoding : utf-8 -*-
require 'coffee-script'

def clean_html?
  false
end


format :html do

  view :editor, :type=>:plain_text
  
  view :core do |args|
    js = compile_coffee _render_raw
    highlighted_js = ::CodeRay.scan( js, :js ).div
    process_content highlighted_js
  end
  
end


format do
  view :core do |args|
    process_content compile_coffee(_render_raw)
  end
  
  def compile_coffee script
    ::CoffeeScript.compile script
  rescue Exception=>e
    e
  end
    
end