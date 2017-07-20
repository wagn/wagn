

format :html do
  # Options
  # @param opts [Hash]
  # @option opts [String, Hash<name, href>] brand
  # @option opts [String] class
  # @option opts [Boolean] no_collapse
  # @option opts [:left, :right] toggle_align
  def navbar id, opts={}
    nav_opts = opts[:navbar_opts] || {}
    nav_opts[:class] ||= opts[:class]
    add_class nav_opts,
              "navbar navbar-inverse bg-#{opts.delete(:navbar_type) || 'primary'}"
    content = yield
    if opts[:no_collapse]
      navbar_nocollapse content, nav_opts
    else
      navbar_responsive id, content, opts, nav_opts
    end
  end

  def navbar_nocollapse content, nav_opts
    content = wrap_with(:div, content)
    wrap_with :nav, content, nav_opts
  end

  def navbar_responsive id, content, opts, nav_opts
    opts[:toggle_align] ||= :right
    wrap_with :nav, nav_opts do
      [
        navbar_header(opts[:brand]),
        navbar_toggle(id, opts[:toggle_align]),
        wrap_with(:div, class: "collapse navbar-collapse",
                  id: "navbar-collapse-#{id}") { content }
      ]
    end
  end

  def navbar_header brand
    return "" unless brand
    if brand.is_a? String
      "<a class='navbar-brand' href='#'>#{brand}</a>"
    else
      link = brand[:href] || "#"
      "<a class='navbar-brand' href='#{link}#'>#{brand[:name]}</a>"
    end
  end

  def navbar_toggle id, align
    content ||= %(<span class="navbar-toggler-icon"></span>)
    <<-HTML
      <button class="navbar-toggler navbar-toggler-#{align}" type="button" data-toggle="collapse" data-target="#navbar-collapse-#{id}" aria-controls="navbar-collapse-#{id}" aria-expanded="false" aria-label="Toggle navigation">
          #{content}
      </button>
    HTML
  end

  def breadcrumb items
    wrap_with :ol, class: "breadcrumb" do
      items.map do |item|
        wrap_with :li, item, class: "breadcrumb-item"
      end.join
    end
  end
end
