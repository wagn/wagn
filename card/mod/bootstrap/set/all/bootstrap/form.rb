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

  FIELD_HELPERS = %w(hidden_field color_field date_field datetime_field
                     datetime_local_field email_field month_field number_field
                     password_field phone_field range_field search_field
                     telephone_field text_area text_field time_field
                     url_field week_field file_field).freeze

  FIELD_HELPERS.each do |method_name|
    define_method(method_name) do |name, options={}|
      form.send(method_name, name, bootstrap_options(options))
    end
  end

  # generate bootstrap column layout
  # @example
  #   layout container: true, fluid: true, class: "hidden" do
  #     row 6, 6, class: "unicorn" do
  #       column "horn",
  #       column "rainbow", class: "colorful"
  #     end
  #   end
  # @example
  #   layout do
  #     row 3, 3, 4, 2, class: "unicorn" do
  #       [ "horn", "body", "tail", "rainbow"]
  #     end
  #     add_html "<span> some extra html</span>"
  #     row 6, 6, ["unicorn", "rainbow"], class: "horn"
  #   end
  def bs_form opts={}, &block
    BootstrapForm.render self, opts, &block
  end

  def bs_horizontal_form *args, &block
    BootstrapHorizontalForm.render self, *args, &block
  end

  class BootstrapForm < BootstrapBuilder
    def render_content *args
      form *args, &@build_block
    end

    add_tag_method :form, nil, optional_classes: {
                                 horizontal: "form-horizontal",
                                 inline: "form-inline" }
    add_div_method :group, "form-group"
    add_tag_method :label, nil
    add_tag_method :input, "form-control" do |opts, extra_args|
      type, label = extra_args
      prepend { label label, for: opts[:id] } if label
      opts[:type] = type
      opts
    end

    [:text, :password, :datetime, :"datetime-local", :date, :month, :time,
     :week, :number, :email, :url, :search, :tel, :color].each do |tag|
      add_tag_method tag, "form-control", attributes: { type: tag },
                                          tag: :input do |opts, extra_args|
        label, = extra_args
        prepend { label label, for: opts[:id] } if label
        opts
      end
    end
  end

  class BootstrapHorizontalForm < BootstrapForm
    add_tag_method :form, "form-horizontal"
    add_tag_method :label, "control-label" do |opts, extra_args|
      prepend_class opts, "col-sm-#{@child_args.last[0]}"
      opts
    end

    add_div_method :input, nil do |opts, extra_args|
      type, label = extra_args
      prepend { tag :label, nil, for: opts[:id] } if label
      insert { inner_input opts.merge(type: type) }
      { class: "col-sm-#{@child_args.last[1]}" }
    end
    add_tag_method :inner_input, "form-control", tag: :input
    add_div_method :inner_checkbox, "checkbox"

    add_div_method :checkbox, nil do |opts, extra_args|
      inner_checkbox do
        label do
          inner_input "checkbox", extra_args.first, opts
        end
      end
      { class: "col-sm-offset-#{@child_args.last[0]} col-sm-#{@child_args.last[1]}" }
    end
  end
end
