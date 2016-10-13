format :html do
  def slot_options args
    options_hash = {}

    if @context_names.present?
      options_hash["name_context"] = @context_names.map(&:key) * ","
    end

    options_hash[:subslot] = "true" if args[:subslot]

    slot_option_keys.each_with_object(options_hash) do |opt, hash|
      hash[opt] = voo.options[opt] if voo.options[opt].present?
    end

    JSON(options_hash)
  end

  def slot_option_keys
    @@slot_option_keys ||= Card::View.option_keys
                                     .reject { |k| k == :view }
                                     .unshift :home_view
  end

  # Does two main things:
  # (1) gives CSS classes for styling and
  # (2) adds card data for javascript - including the "card-slot" class,
  #     which in principle is not supposed to be in styles
  def wrap args={}
    @slot_view = @current_view
    classes = wrap_classes args
    data = wrap_data args

    div = content_tag :div, output(yield).html_safe,
                      id: card.cardname.url_key,
                      class: classes,
                      data: data,
                      style: h(voo.style)
    add_debug_comments div
  end

  def add_debug_comments content
    return content if params[:debug] != "slot" ||
                      tagged(@current_view, :no_wrap_comments)
    name = h card.name
    space = "  " * @depth
    "<!--\n\n#{space}BEGIN SLOT: #{name}\n\n-->" \
    "#{div}" \
    "<!--\n\n#{space}END SLOT: #{name}\n\n-->"
  end

  def wrap_classes args
    [
      ("card-slot" unless args[:no_slot]),
      "#{@current_view}-view",
      (args[:slot_class] if args[:slot_class]),
      ("STRUCTURE-#{voo.structure.to_name.key}" if voo.structure),
      card.safe_set_keys
    ].compact.join " "
  end

  def wrap_data args
    {
      "card-id" => card.id,
      "card-name" => h(card.name),
      "slot"      => html_escape_except_quotes(slot_options(args))
    }
  end

  def wrap_body args={}
    css_classes = ["card-body"]
    css_classes << args[:body_class]                      if args[:body_class]
    css_classes += ["card-content", card.safe_set_keys] if args[:content]
    content_tag :div, class: css_classes.compact * " " do
      yield args
    end
  end

  def panel args={}
    wrap_with :div, class: "card-frame #{args[:panel_class]}" do
      output(yield)
    end
  end

  def frame args={}, &block
    wrap args do
      [
        _optional_render(:menu, args),
        panel(args) do
          [
            _optional_render(:header, args, :show),
            #_optional_render(:subheader, args,
            #                 (show_subheader ? :show : :hide)),
            _optional_render(:help, { help_class: "alert alert-info" }, :hide),
            wrap_body(args) { output(yield(args)) }
          ]
        end
      ]
    end
  end

  def subframe args={}
    wrap args do
      [
        _optional_render(:menu, args.merge(optional_horizontal_menu: :hide)),
        _optional_render(:subheader, args, :show),
        _optional_render(:help, args.merge(help_class: "alert alert-info"),
                         :hide),
        panel(args) do
          [
            _optional_render(:header, args, :hide),
            wrap_body(args) { output(yield args) }
          ]
        end
      ]
    end
  end

  def frame_and_form action, frame_opts={}, form_opts={}
    frame frame_optsv do
      card_form action, form_opts do
        output(yield)
      end
    end
  end

  # alert_types: 'success', 'info', 'warning', 'danger'
  def alert alert_type, args={}
    css_class = "alert alert-#{alert_type} "
    css_class += "alert-dismissible " if args[:dismissible]
    css_class += args[:alert_class] if args[:alert_class]
    close_button =
      if args[:dismissible]
        <<-HTML
          <button type="button" class="close" data-dismiss="alert"
                  aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        HTML
      else
        ""
      end
    content_tag :div, class: css_class, role: "alert" do
      close_button + output(yield args)
    end
  end

  def wrap_main content
    return content if Env.ajax? || params[:layout] == "none"
    %(<div id="main">#{content}</div>)
  end

  def wrap_with tag, content_or_args={}, html_args={}
    if block_given?
      content_tag(tag, content_or_args) do
        output(yield).html_safe
      end
    else
      content_tag(tag, html_args) do
        output(content_or_args).html_safe
      end
    end
  end

  def wrap_each_with tag, content_or_args={}, args={}
    content = block_given? ? yield(args) : content_or_args
    args    = block_given? ? content_or_args : args
    content.compact.map do |item|
      wrap_with tag, args do
        item
      end
    end.join "\n"
  end
end
