format :html do
  def toolbar_split_button name, button_link_opts
    status = active_toolbar_button == name ? "active" : ""
    html_class = "visible-md visible-lg pull-right"
    icon = button_link_opts.delete(:icon)
    name_content = "&nbsp;#{name}"
    name = icon ? glyphicon(icon) : ""
    name += content_tag(:span, name_content.html_safe, class: html_class)
    button_link = button_link name, button_link_opts.merge(class: status)
    split_button(button_link, active_toolbar_item) {yield}
  end

  def subject
    parent || self
  end
end