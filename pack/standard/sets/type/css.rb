# -*- encoding : utf-8 -*-

format :html do

  view :editor, :type=>:plain_text
  
  view :core do |args|
    ::CodeRay.scan( process_content(_render_raw), :css ).div 
  end
  
end