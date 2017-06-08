format :html do
  def glyphicon icon_type, extra_class=""
    wrap_with :span, "",
              "aria-hidden" => true,
              class: "glyphicon glyphicon-#{icon_type} #{extra_class}"
  end

  def button_link link_text, opts={}
    btn_type = opts.delete(:btn_type) || "primary"
    opts[:class] = [opts[:class], "btn btn-#{btn_type}"].compact.join " "
    smart_link_to link_text, opts.merge(type: "button")
  end

  def dropdown_button name, opts={}
    <<-HTML
      <div class="btn-group" role="group">
        <button type="button" class="btn btn-primary dropdown-toggle"
                data-toggle="dropdown" title="#{name}" aria-expanded="false"
                aria-haspopup="true">
          #{glyphicon opts[:icon] if opts[:icon]} #{name}
          <span class="caret"></span>
        </button>
        #{dropdown_list yield, opts[:class], opts[:active]}
      </div>
    HTML
  end

  def dropdown_list items, extra_css_class=nil, active=nil
    wrap_with :ul, class: "dropdown-menu #{extra_css_class}", role: "menu" do
      case items
      when Array
        items.map.with_index { |item, i| dropdown_list_item item, i, active }
      when Hash
        items.map { |key, item| dropdown_list_item item, key, active }
      else
        [items]
      end.compact.join "\n"
    end
  end

  def dropdown_list_item item, active_test, active
    return unless item
    "<li #{'class=\'active\'' if active_test == active}>#{item}</li>"
  end

  def separator
    '<li role="separator" class="divider"></li>'
  end

  def split_button main_button, active_item
    wrap_with :div, class: "btn-group" do
      [
        main_button,
        split_button_toggle,
        dropdown_list(yield, nil, active_item)
      ]
    end
  end

  def split_button_toggle
    button_tag(situation: "primary",
               class: "dropdown-toggle",
               "data-toggle" => "dropdown",
               "aria-haspopup" => "true",
               "aria-expanded" => "false") do
      '<span class="caret"></span><span class="sr-only">Toggle Dropdown</span>'
    end
  end

  def list_group content_or_options=nil, options={}
    options = content_or_options if block_given?
    content = block_given? ? yield : content_or_options
    content = Array(content).map(&:to_s)
    add_class options, "list-group"
    options[:items] ||= {}
    add_class options[:items], "list-group-item"
    list_tag content, options
  end

  def list_tag content_or_options=nil, options={}
    options = content_or_options if block_given?
    content = block_given? ? yield : content_or_options
    content = Array(content)
    default_item_options = options.delete(:items) || {}
    wrap_with :ul, options do
      content.map do |item|
        i_content, i_opts = item
        i_opts ||= default_item_options
        wrap_with :li, i_content, i_opts
      end
    end
  end
end
