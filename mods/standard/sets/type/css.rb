# -*- encoding : utf-8 -*-

format :html do

  view :editor, :type=>:plain_text
  
  view :core do |args|
    # FIXME: scan must happen before process for inclusion interactions to work, but this will likely cause
    # problems with including other css?
    process_content ::CodeRay.scan( _render_raw, :css ).div, :size=>:icon
  end
  
end

event :reset_style_for_css, :after=>:store do
  Card::Set::Right::Style.delete_style_files
end
