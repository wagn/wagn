# -*- encoding : utf-8 -*-
require 'uglifier'

include Machine
include MachineInput

store_machine_output :filetype => "js"

machine_input do 
  Uglifier.compile(format(:js)._render_core)
end


def clean_html?
  false
end


format do
  def chunk_list  #turn off autodetection of uri's 
    :inclusion_only
  end
end

format :html do
  view :editor, :mod=>PlainText::HtmlFormat
  view :content_changes, :mod=>CoffeeScript::HtmlFormat
  
  view :core do |args|
    highlighted_js = ::CodeRay.scan( _render_raw, :js ).div
    process_content highlighted_js
  end
  
end

def diff_args
   {:format=>:text}
end
