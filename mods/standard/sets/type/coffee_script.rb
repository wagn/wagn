# -*- encoding : utf-8 -*-
#require 'coffee-script'
include Machine
include MachineInput


machine_input do 
  compile_coffee format._render_raw
end

store_machine_output :filetype => "js"

def clean_html?
  false
end


def compile_coffee script
  Uglifier.compile(::CoffeeScript.compile script)
rescue Exception=>e
  e
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
    wagnprocess_content compile_coffee(_render_raw)
  end
    
end