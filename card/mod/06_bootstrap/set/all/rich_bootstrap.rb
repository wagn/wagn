format :html do

  def glyphicon icon_type, extra_class=''
    content_tag(:span, '', :class=>"glyphicon glyphicon-#{icon_type} #{extra_class}", 'aria-hidden'=>true)
  end


  # Options
  # :header => { :content=>String, :brand=>( String | {:name=>, :href=>} ) }
  def navbar id, opts={}
    nav_opts = opts[:nav_opts] || {}
    nav_opts[:class] ||= (opts[:class] || '')
    nav_opts[:class] += " navbar navbar-#{opts.delete(:navbar_type) || 'default'}"
    header_opts = opts[:header] || {}
    if opts[:toggle_align] == :left
      opts[:collapsed_content] ||= ''
      opts[:collapsed_content] += navbar_toggle(id, opts[:toggle], 'pull-left navbar-link').html_safe
      opts[:toggle] = :hide
    end
    wrap_with :nav, nav_opts do
      [
        navbar_header(id, header_opts.delete(:content), header_opts.reverse_merge(:toggle=>opts[:toggle])),
        (content_tag(:div, opts[:collapsed_content].html_safe, :class=>'container-fluid') if opts[:collapsed_content]),
        content_tag(:div, output(yield).html_safe, :class=>"collapse navbar-collapse", :id=>"navbar-collapse-#{id}"),
      ]
    end
  end

  def navbar_header id, content='', opts={}
    brand = if opts[:brand]
              if opts[:brand].kind_of? String
                "<a class='navbar-brand' href='#'>#{opts[:brand]}</a>"
              else
                link = opts[:brand][:href] || '#'
                "<a class='navbar-brand' href='#{link}#'>#{opts[:brand][:name]}</a>"
              end
            end
    wrap_with :div, :class=>'navbar-header' do
      [
        (navbar_toggle(id, opts[:toggle]) unless opts[:toggle] == :hide),
        brand,
        (content if content)
      ]
    end
  end

  def navbar_toggle id, content=nil, css_class=''
    content ||= %{
                  <span class="icon-bar"></span>
                  <span class="icon-bar"></span>
                  <span class="icon-bar"></span>
                }
    %{
      <button type="button" class="navbar-toggle collapsed #{css_class}" data-toggle="collapse" data-target="#navbar-collapse-#{id}">
        <span class="sr-only">Toggle navigation</span>
        #{content}
      </button>
    }
  end


  view :closed do |args|
    args.merge! :body_class=>'closed-content'
    super args
  end

end
