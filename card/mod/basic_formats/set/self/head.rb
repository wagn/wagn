format :html do
  view :raw do
    output [
      head_meta,
      head_title,
      head_buttons,
      head_stylesheets,
      head_javascript
    ]
  end

  view :core do |args|
    if focal?
      CGI.escapeHTML _render_raw(args)
    elsif @mainline
      "(*head)"
    else
      _render_raw(args)
    end
  end

  def head_meta
    <<-HTML
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    HTML
  end

  def head_title
    title = root.card && root.card.name
    title = nil if title.blank?
    title = params[:action] if title == "*placeholder"
    %(<title>#{title ? "#{title} - " : ''}#{Card.global_setting :title}</title>)
  end

  def head_buttons
    bits = [favicon]
    if root.card
      bits << universal_edit_button
      # RSS # move to mods!
      bits << rss_link if root.card.type_id == SearchTypeID
    end
    bits.compact.join "\n      "
  end

  def head_stylesheets
    manual_style = params[:style]
    style_card = Card[manual_style] if manual_style
    style_card ||= root.card.rule_card :style
    @css_path =
      if params[:debug] == "style"
        page_path(style_card.cardname, item: :import, format: :css)
      elsif style_card
        card_path style_card.machine_output_url
      end
    return unless @css_path
    %(<link href="#{@css_path}" media="all" rel="stylesheet" type="text/css" />)
  end

  def head_javascript
    output [
      wagn_variables,
      script_rule,
      ie9,
      mod_configs,
      trigger_slot_ready,
      google_analytics
    ]
  end

  def favicon
    [:favicon, :logo].each do |name|
      if (c = Card[name]) && c.type_id == ImageID && !c.db_content.blank?
        href = subformat(c)._render_source size: :small
        return %(<link rel="shortcut icon" href="#{href}" />)
      end
    end
  end

  def universal_edit_button
    return if root.card.new_record? || !root.card.ok?(:update)
    href = root.path view: :edit
    tag "link", rel: "alternate", type: "application/x-wiki",
                title: "Edit this page!", href: href
  end

  def rss_link
    opts = { format: :rss }
    root.search_params[:vars].each { |key, val| opts["_#{key}"] = val }
    href = page_path root.card.cardname, opts
    tag "link", rel: "alternate", type: "application/rss+xml",
                title: "RSS", href: href
  end
end
