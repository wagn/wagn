# -*- encoding : utf-8 -*-
#require 'coffee-script'

include Machine
include MachineInput

store_machine_output :filetype => "js"

machine_input do 
  Uglifier.compile(format._render_raw)
end


def clean_html?
  false
end


format :html do

  view :editor, :type=>:plain_text
  
  view :core do |args|
    highlighted_js = ::CodeRay.scan( _render_raw, :js ).div
    process_content highlighted_js
  end
  
end


format do
  view :core do |args|
    process_content _render_raw
  end
    
end