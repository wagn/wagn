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
  
  def bootstrap_options options
    options[:class] ||= ''
    options[:class] += ' form-control'
    options
  end
  
  FIELD_HELPERS = %w{hidden_field color_field date_field datetime_field datetime_local_field
    email_field month_field number_field password_field phone_field
    range_field search_field telephone_field text_area text_field time_field
    url_field week_field file_field}


  FIELD_HELPERS.each do |method_name|
    define_method(method_name) do |name, options = {}|
      if_form_given do |form|
        form.send(method_name, name, bootstrap_options(options) )
      end
    end
  end
  
  def check_box method, options={}, checked_value = "1", unchecked_value = "0"
    if_form_given do |form|
      form.check_box method, bootstrap_options(options), checked_value, unchecked_value
    end
  end
  
  def radio_button method, tag_value, options = {}
    if_form_given do |form|
      form.radio_button method, tag_value, bootstrap_options(options)
    end
  end
  
end
