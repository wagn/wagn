format :html do
  def button_tag content_or_options=nil, options={}, &block
    bootstrapify_button(block_given? ? content_or_options : options)
    super(content_or_options, options, &block)
  end

  def bootstrapify_button options
    situation = options.delete(:situation) || "default"
    options[:class] = [options[:class], "btn", "btn-#{situation}"].compact * " "
  end

  def type_field args={}
    args[:class] ||= ""
    args[:class] += " form-control"
    super(args)
  end

  def bootstrap_options options
    options[:class] ||= ""
    options[:class] += " form-control"
    options
  end

  FIELD_HELPERS = %w(hidden_field color_field date_field datetime_field datetime_local_field
                     email_field month_field number_field password_field phone_field
                     range_field search_field telephone_field text_area text_field time_field
                     url_field week_field file_field).freeze

  FIELD_HELPERS.each do |method_name|
    define_method(method_name) do |name, options={}|
      form.send(method_name, name, bootstrap_options(options))
    end
  end
end
