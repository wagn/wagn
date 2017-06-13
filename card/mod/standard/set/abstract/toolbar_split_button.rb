format :html do
  def toolbar_split_button name, button_link_opts
    button_link = toolbar_split_button_link name, button_link_opts
    split_button(button_link, active_toolbar_item) { yield }
  end

  def toolbar_split_button_link name, opts
    link_text = toolbar_split_button_link_text name, opts
    opts[:class] = "active" if active_toolbar_button == name
    button_link link_text, opts
  end

  def toolbar_split_button_link_text name, opts
    icon = glyphicon opts.delete(:icon)
    icon + content_tag(:span, "&nbsp;#{name}".html_safe,
                       class: "visible-md visible-lg pull-right")
  end

  def subject
    parent || self
  end
end
