format :html do
  # @param tab_type [String] 'tabs' or 'pills'
  # @param tabs [Hash] keys are the labels, values the content for the tabs
  # @param active_name [String] label of the tab that should be active at the
  # beginning (default is the first)
  # @return [HTML] bootstrap tabs element with all content preloaded
  def static_tabs tabs, active_name=nil,  tab_type="tabs"
    tab_buttons = ""
    tab_panes = ""
    tabs.each do |tab_name, tab_content|
      active_name ||= tab_name
      active_tab = (tab_name == active_name)
      id = "#{card.cardname.safe_key}-#{tab_name.to_name.safe_key}"
      tab_buttons += tab_button("##{id}", tab_name, active_tab)
      tab_panes += tab_pane(id, tab_content, active_tab)
    end
    tab_panel tab_buttons, tab_panes, tab_type
  end

  # @param [Hash] tabs keys are the labels for the tabs, values the urls to
  # load the content from
  # @param [String] active_name label of the tab that should be active at the
  # beginning
  # @param [String] active_content content of the active tab
  # @param [Hash] args options
  # @option args [String] :type ('tabs') use pills or tabs
  # @option args [Hash] :panel_args html args used for the panel div
  # @option args [Hash] :pane_args html args used for the pane div
  # @return [HTML] bootstrap tabs element with content only for the active
  # tab; other tabs get loaded via ajax when selected
  def lazy_loading_tabs tabs, active_name, active_content, args={}
    tab_buttons = ""
    tab_panes = ""
    tabs.each do |tab_name, url|
      active_tab = (active_name == tab_name)
      id = "#{card.cardname.safe_key}-#{tab_name.to_name.safe_key}"
      tab_buttons += tab_button(
        "##{id}", tab_name, active_tab,
        "data-url" => url.html_safe,
        class: (active_tab ? nil : "load")
      )
      tab_content = active_tab ? active_content : ""
      tab_panes += tab_pane(id, tab_content, active_tab, args[:pane_args])
    end
    tab_type = args.delete(:type) || "tabs"
    tab_panel tab_buttons, tab_panes, tab_type, args[:panel_args]
  end

  def tab_panel tab_buttons, tab_panes, tab_type="tabs", args=nil
    args ||= {}
    add_class args, "tabbable"
    args.reverse_merge! role: "tabpanel"
    wrap_with :div, args do
      [
        content_tag(:ul, tab_buttons.html_safe,
                    class: "nav nav-#{tab_type}",
                    role: "tablist"),
        content_tag(:div, tab_panes.html_safe, class: "tab-content")
      ]
    end
  end

  def tab_button target, text, active=false, link_attr={}
    link = link_to(
      fancy_title(text),
      target,
      link_attr.merge("role" => "tab", "data-toggle" => "tab"))
    li_args = { role: :presentation }
    li_args[:class] = "active" if active
    content_tag :li, link, li_args
  end

  def tab_pane id, content, active=false, args=nil
    args ||= {}
    args.reverse_merge! role: :tabpanel,
                        id: id
    add_class args, "tab-pane"
    add_class args, "active" if active
    content_tag :div, content.html_safe, args
  end
end
