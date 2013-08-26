# -*- encoding : utf-8 -*-

format :html do

  view :editor, :type=>:plain_text
  
  view :core do |args|
    css = super args
    ::CodeRay.scan( css, :css ).div
  end
  
end


format do
  view :core do |args|
    scss = process_content _render_raw
    begin
      Sass.compile scss, :style=>:expanded
    rescue Exception=>e
      e
    end
  end
end
