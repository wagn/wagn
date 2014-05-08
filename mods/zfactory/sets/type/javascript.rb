# -*- encoding : utf-8 -*-
require 'coffee-script'

include Factory
include Supplier

store_factory_product :filetype => "js"

deliver do 
  compress_javascript script
end

def compress_javascript script
  script
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