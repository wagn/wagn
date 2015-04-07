format :html do

  def glyphicon icon_type, extra_class=''
    content_tag(:span, '', :class=>"glyphicon glyphicon-#{icon_type} #{extra_class}", 'aria-hidden'=>true)
  end


  # Options
  # :header => { :content=>String, :brand=>( String | {:name=>, :href=>} ) }
  def navbar id, header={}, opts={}
    opts[:class] ||= ''
    opts[:class] += "navbar navbar-default"
    wrap_with :nav, :class=>opts[:class] do
      [
        navbar_header(id, header.delete(:content), header),
        content_tag(:div, output(yield).html_safe, :class=>"collapse navbar-collapse", :id=>"navbar-collapse-#{id}")
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
    %{
      <div class="navbar-header">
         <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse-#{id}">
           <span class="sr-only">Toggle navigation</span>
           <span class="icon-bar"></span>
           <span class="icon-bar"></span>
           <span class="icon-bar"></span>
         </button>
         #{brand}
         #{content if content}
       </div>
     }.html_safe
  end



  view :closed do |args|
    args.merge! :body_class=>'closed-content'
    super args
  end

end
