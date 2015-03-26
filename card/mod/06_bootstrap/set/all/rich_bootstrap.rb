format :html do
  
  def glyphicon icon_type, extra_class=''
    content_tag(:span, '', :class=>"glyphicon glyphicon-#{icon_type} #{extra_class}", 'aria-hidden'=>true)
  end
  
  view :closed do |args|
    args.merge! :body_class=>'closed-content'
    super args
  end
  
end