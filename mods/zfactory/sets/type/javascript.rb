# -*- encoding : utf-8 -*-
require 'coffee-script'

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