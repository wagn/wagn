format :html do
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

  def breadcrumb items
    content_tag :ol, class: "breadcrumb" do
      items.map do |item|
        content_tag :li, item, class: "breadcrumb-item"
      end.join
    end
  end
end
