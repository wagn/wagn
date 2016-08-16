
view :core do |_args|
  case card.raw_content.to_i
  when 1 then "yes"
  when 0 then "no"
  else; "?"
  end
end

view :editor do |_args|
  check_box :content
end
