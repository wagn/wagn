# -*- encoding : utf-8 -*-


view :editor do |args|
  form.text_area :content, :rows=>15, :class=>'card-content'
end

view :core do |args|
  h _render_raw
end

module Model
  def clean_html?
    false
  end
end
