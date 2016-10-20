format :html do

  def slot_option_keys
    @@slot_option_keys ||= Card::View.option_keys
                                     .reject { |k| k == :view }
                                     .unshift :home_view
  end

  # Does two main things:
  # (1) gives CSS classes for styling and
  # (2) adds card data for javascript - including the "card-slot" class,
  #     which in principle is not supposed to be in styles
  def wrap slot=true
    @slot_view = @current_view
    debug_slot do
      wrap_with(:div, id: card.cardname.url_key,
                      class: wrap_classes(slot),
                      data:  wrap_data) { yield }
    end
  end

  def wrap_data
    { "card-id"           => card.id,
      "card-name"         => h(card.name),
      "slot"              => voo.slot_options(@context_names) }
  end

  def debug_slot
    debug_slot? ? debug_slot_wrap { yield } : yield
  end

  def debug_slot?
    params[:debug] == "slot" && !tagged(@current_view, :no_wrap_comments)
  end

  def debug_slot_wrap
    pre = "<!--\n\n#{'  ' * @depth}"
    post = " SLOT: #{h card.name}\n\n-->"
    [pre, "BEGIN", post, yield, pre, "END", post].join
  end

  def wrap_classes slot
    list = ["card-slot", "#{@current_view}-view", card.safe_set_keys]
    list.push "STRUCTURE-#{voo.structure.to_name.key}" if voo.structure
    list.shift unless slot
    classy list
  end

  def wrap_body
    css_classes = ["card-body"]
    css_classes += ["card-content", card.safe_set_keys] if @content_body
    wrap_with :div, class: classy(*css_classes) do
      yield
    end
  end

  def panel
    wrap_with :div, class: classy("card-frame") do
      yield
    end
  end

  def related_frame
    wrap do
      [
        _optional_render_menu,
        _optional_render_related_subheader,
        frame_help,
        panel { wrap_body { yield } }
      ]
    end
  end

  def frame
    voo.hide :horizontal_menu, :help
    wrap do
      [
        _optional_render_menu,
        panel do
          [
            _optional_render_header,
            frame_help,
            wrap_body { yield }
          ]
        end
      ]
    end
  end

  def frame_help
    _optional_render :help, help_class: "alert alert-info"
  end

  def frame_and_form action, form_opts={}
    frame do
      card_form action, form_opts do
        output yield
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
    wrap_with :div, content, id: "main"
  end

  def wrap_with tag, content_or_args={}, html_args={}
    content = block_given? ? yield : content_or_args
    tag_args = block_given? ? content_or_args : html_args
    content_tag(tag, tag_args) { output(content).to_s.html_safe }
  end

  def wrap_each_with tag, content_or_args={}, args={}
    content = block_given? ? yield(args) : content_or_args
    args    = block_given? ? content_or_args : args
    content.compact.map do |item|
      wrap_with(tag, args) { item }
    end.join "\n"
  end
end
