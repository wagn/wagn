format :html do
  def glyphicon icon_type, extra_class=""
    content_tag(
      :span, "",
      class: "glyphicon glyphicon-#{icon_type} #{extra_class}",
      "aria-hidden" => true
    )
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
    item_list =
      case items
      when Array
        items.map.with_index do |item, index|
          "<li #{'class=\'active\'' if index == active}>#{item}</li>" if item
        end.compact.join "\n"
      when Hash
        items.map do |key, item|
          "<li #{'class=\'active\'' if key == active}>#{item}</li>" if item
        end.compact.join "\n"
      else
        items
      end
    %(
      <ul class="dropdown-menu #{extra_css_class}" role="menu">
        #{item_list}
      </ul>
    )
  end

  def separator
    '<li role="separator" class="divider"></li>'
  end

  def split_button button, args={}
    items = yield
    args[:situation] ||= "primary"

    wrap_with :div, class: "btn-group" do
      [
        button,
        button_tag(situation: args[:situation],
                   class: "dropdown-toggle", "data-toggle" => "dropdown",
                   "aria-haspopup" => "true", "aria-expanded" => "false") do
          <<-HTML
            <span class="caret"></span>
            <span class="sr-only">Toggle Dropdown</span>
          HTML
        end,
        dropdown_list(items, nil, args[:active_item])
      ]
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
    wrap_with :ul, options  do
      content.map do |item|
        i_content, i_opts = item
        i_opts ||= default_item_options
        content_tag :li, i_content.html_safe, i_opts
      end.join "\n"
    end
  end
end
