def checked?
  content == "1"
end

view :core do |_args|
  case card.raw_content.to_i
  when 1 then "yes"
  when 0 then "no"
  else
    "?"
  end
end

format :html do
  view :editor do
    toggle
  end

  view :labeled_editor do
    toggle + toggle_label
  end

  def toggle
    check_box :content
  end

  def toggle_label
    label :content, card.cardname.tag
  end
end


