format :html do
  def glyphicon icon_type, extra_class=""
    content_tag(
      :span, "",
      class: "glyphicon glyphicon-#{icon_type} #{extra_class}",
      "aria-hidden" => true
    )
  end

  def button_link link_text, target, html_args={}
    html_args[:class] ||= ""
    btn_type = html_args[:btn_type] || "primary"
    html_args[:class] +=  " btn btn-#{btn_type}"
    smart_link link_text, target, html_args.merge(type: "button")
  end

  def dropdown_button name, opts={}
    <<-HTML
      <div class="btn-group" role="group">
        <button type="button" class="btn btn-primary dropdown-toggle"
                data-toggle="dropdown" title="#{name}" aria-expanded="false"
                aria-haspopup="true">
          #{glyphicon opts[:icon] if opts[:icon]} #{name}
          <span class="caret"></span>
        </button>
        #{dropdown_list yield, opts[:class], opts[:active]}
      </div>
    HTML
  end

  def dropdown_list items, extra_css_class=nil, active=nil
    item_list =
      case items
      when Array
        items.map.with_index do |item, index|
          "<li #{'class=\'active\'' if index == active}>#{item}</li>" if item
        end.compact.join "\n"
      when Hash
        items.map do |key, item|
          "<li #{'class=\'active\'' if key == active}>#{item}</li>" if item
        end.compact.join "\n"
      else
        items
      end
    %(
      <ul class="dropdown-menu #{extra_css_class}" role="menu">
        #{item_list}
      </ul>
    )
  end

  def separator
    '<li role="separator" class="divider"></li>'
  end

  def breadcrumb items
    content_tag :ol, class: "breadcrumb" do
      items.map do |item|
        content_tag :li, item, class: "breadcrumb-item"
      end.join
    end
  end

  # Options
  # header: { content: String, brand: ( String | {name: , href: } ) }
  def navbar id, opts={}
    nav_opts = opts[:navbar_opts] || {}
    nav_opts[:class] ||= opts[:class]
    add_class nav_opts,
              "navbar navbar-#{opts.delete(:navbar_type) || 'default'}"
    header_opts = opts[:header] || {}
    if opts[:toggle_align] == :left
      opts[:toggle] = :hide
      opts[:collapsed_content] ||= ""
      opts[:collapsed_content] +=
        navbar_toggle(
          id, opts[:toggle], "pull-left navbar-link"
        ).html_safe
    end
    wrap_with :nav, nav_opts do
      [
        navbar_header(id, header_opts.delete(:content),
                      header_opts.reverse_merge(toggle: opts[:toggle])),
        navbar_collapsed_content(opts[:collapsed_content]),
        content_tag(:div, output(yield).html_safe,
                    class: "collapse navbar-collapse",
                    id: "navbar-collapse-#{id}")
      ]
    end
  end

  def navbar_collapsed_content content
    content_tag(:div, content.html_safe, class: "container-fluid") if content
  end

  def navbar_header id, content="", opts={}
    brand =
      if opts[:brand]
        if opts[:brand].is_a? String
          "<a class='navbar-brand' href='#'>#{opts[:brand]}</a>"
        else
          link = opts[:brand][:href] || "#"
          "<a class='navbar-brand' href='#{link}#'>#{opts[:brand][:name]}</a>"
        end
      end
    wrap_with :div, class: "navbar-header" do
      [
        (navbar_toggle(id, opts[:toggle]) unless opts[:toggle] == :hide),
        brand,
        (content if content)
      ]
    end
  end

  def navbar_toggle id, content=nil, css_class=""
    content ||= %(
                  <span class="icon-bar"></span>
                  <span class="icon-bar"></span>
                  <span class="icon-bar"></span>
                )
    <<-HTML
      <button type="button" class="navbar-toggle collapsed #{css_class}"
              data-toggle="collapse" data-target="#navbar-collapse-#{id}">
        <span class="sr-only">Toggle navigation</span>
        #{content}
      </button>
    HTML
  end

  def split_button button, args={}
    items = yield
    args[:situation] ||= "primary"

    wrap_with :div, class: "btn-group" do
      [
        button,
        button_tag(situation: args[:situation],
                   class: "dropdown-toggle", "data-toggle" => "dropdown",
                   "aria-haspopup" => "true", "aria-expanded" => "false") do
          <<-HTML
            <span class="caret"></span>
            <span class="sr-only">Toggle Dropdown</span>
          HTML
        end,
        dropdown_list(items, nil, args[:active_item])
      ]
    end
  end

  def list_group content_or_options=nil, options={}
    options = content_or_options if block_given?
    content = block_given? ? yield : content_or_options
    content = Array(content).map(&:to_s)
    add_class options, "list-group"
    options[:items] ||= {}
    add_class options[:items], "list-group-item"
    list_tag content, options
  end

  def list_tag content_or_options=nil, options={}
    options = content_or_options if block_given?
    content = block_given? ? yield : content_or_options
    content = Array(content)
    item_options = options.delete(:items) || {}
    wrap_with :ul, options  do
      content.map do |item|
        content_tag :li, item.html_safe, item_options
      end.join "\n"
    end
  end

  def accordion_group list, collapse_id=card.cardname.safe_key
    accordions = ""
    index = 1
    list.each_pair do |title, content|
      accordions << accordion(title, content, "#{collapse_id}-#{index}")
      index += 1
    end
    content_tag :div, accordions.html_safe,
                class: "panel-group",
                id: "accordion-#{collapse_id}",
                role: "tablist",
                "aria-multiselectable" => "true"
  end

  private

  def accordion title, content, collapse_id=card.cardname.safe_key
    accordion_content =
      case content
      when Hash  then accordion_group(content, collapse_id)
      when Array then content.present? && list_group(content)
      when String then content
      end
    <<-HTML.html_safe
      <div class="panel panel-default">
        #{accordion_panel(title, accordion_content, collapse_id)}
      </div>
    HTML
  end

  def accordion_panel title, body, collapse_id
    if body
      <<-HTML
        <div class="panel-heading" role="tab" id="heading-#{collapse_id}">
          <h4 class="panel-title">
            <a data-toggle="collapse" data-parent="#accordion-#{collapse_id}" \
               href="##{collapse_id}" aria-expanded="true" \
               aria-controls="#{collapse_id}">
              #{title}
            </a>
          </h4>
        </div>
        <div id="#{collapse_id}" class="panel-collapse collapse" \
               role="tabpanel" aria-labelledby="heading-#{collapse_id}">
          <div class="panel-body">
            #{body}
          </div>
        </div>
      HTML
    else
      <<-HTML
        <li class="list-group-item">
          <h4 class="panel-title">#{title}</h4>
        </li>
      HTML
    end
  end
end
