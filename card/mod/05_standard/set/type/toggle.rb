
view :core do |args|
  case card.raw_content.to_i
  when 1; 'yes'
  when 0; 'no'
  else  ; '?'
  end
end

view :editor do |args|
  check_box :content
end
