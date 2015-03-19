format :html do
  
  def glyphicon icon_type
    content_tag(:span, '', :class=>"glyphicon glyphicon-#{icon_type}", 'aria-hidden'=>true)
  end
  
  view :closed do |args|
    args.merge! :body_class=>'closed-content'
    super args
  end
  
end