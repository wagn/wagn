format :html do
  def button_tag content_or_options = nil, options = {}, &block
    if block_given?
      content_or_options[:class] ||= ''
      content_or_options[:class] += ' btn btn-default'
    else
      options[:class] ||= ''
      options[:class] += ' btn btn-default'
    end
    super(content_or_options, options, &block)
  end
  
  def type_field args={}
    args[:class] ||= ''
    args[:class] += ' form-control'
    super(args)
  end
end
