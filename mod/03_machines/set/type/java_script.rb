# -*- encoding : utf-8 -*-
require 'uglifier'

include Machine
include MachineInput

store_machine_output :filetype => "js"

machine_input do 
  Uglifier.compile(format(:format=>:js)._render_core)
end


def clean_html?
  false
end

def chunk_list  #turn off autodetection of uri's 
                #TODO with the new format pattern this should be handled in the js format
  :inclusion_only
end

format :html do

  view :editor, :mod=>PlainText::HtmlFormat
  
  view :core do |args|
    highlighted_js = ::CodeRay.scan( _render_raw, :js ).div
    process_content highlighted_js
  end
  
  view :content_changes do |args|
    %{
      <pre>#{super(args)}</pre>
    }
  end
  
end

def diff_args
   {:format=>:text}
end
