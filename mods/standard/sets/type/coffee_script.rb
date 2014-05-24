# -*- encoding : utf-8 -*-
require 'byebug'
include Machine
include MachineInput

def compile_coffee script
  Uglifier.compile(::CoffeeScript.compile script)
rescue Exception=>e
  e
end

machine_input do 
  compile_coffee format(:format=>:js)._render_raw
end

store_machine_output :filetype => "js"

def clean_html?
  false
end

def chunk_list  #turn off autodetection of uri's 
                #TODO with the new format pattern this should be handled in the js format
  :inclusion_only
end


format :html do
  def compile_coffee script
    Uglifier.compile(::CoffeeScript.compile script)
  rescue Exception=>e
    e
  end
  
  view :editor, :type=>:plain_text
  
  view :core do |args|
    js = compile_coffee _render_raw
    highlighted_js = ::CodeRay.scan( js, :js ).div
    process_content highlighted_js
  end
  
end


format do
  def compile_coffee script
    Uglifier.compile(::CoffeeScript.compile script)
  rescue Exception=>e
    e
  end
  
  view :core do |args|
    process_content compile_coffee(_render_raw)
  end
end