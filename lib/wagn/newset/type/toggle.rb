# -*- encoding : utf-8 -*-

define_view :core do |args|
  case card.raw_content.to_i
    when 1; 'yes'
    when 0; 'no'
    else  ; '?'
    end
end

define_view :editor do |args|
  form.check_box :content
end
