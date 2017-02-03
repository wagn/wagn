format :html do
  def success_tags opts
    return "" unless opts
    hidden_tags success: opts
  end

  def hidden_tags hash, base=nil
    # convert hash into a collection of hidden tags
    result = ""
    hash ||= {}
    hash.each do |key, val|
      result +=
        if val.is_a?(Hash)
          hidden_tags val, key
        else
          name = base ? "#{base}[#{key}]" : key
          hidden_field_tag name, val
        end
    end
    result
  end

  FIELD_HELPERS =
    %w(
      hidden_field color_field date_field datetime_field datetime_local_field
      email_field month_field number_field password_field phone_field
      range_field search_field telephone_field text_area text_field time_field
      url_field week_field file_field label check_box radio_button
    ).freeze

  FIELD_HELPERS.each do |method_name|
    define_method(method_name) do |*args|
      form.send(method_name, *args)
    end
  end

  def submit_button args={}
    text = args.delete(:text) || "Submit"
    args.reverse_merge! situation: "primary", data: {}
    args[:data][:disable_with] ||= args.delete(:disable_with) || "Submitting"
    button_tag text, args
  end

  # redirect to *previous if no :href is given
  def cancel_button args={}
    text = args.delete(:text) || "Cancel"
    args[:type] ||= "button"
    add_class args, (args[:href] ? "slotter" : "redirecter")
    args[:href] ||= Card.path_setting("/*previous")
    button_tag text, args
  end
end
