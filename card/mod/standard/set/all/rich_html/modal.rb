format :html do
  view :modal_link do |args|
    opts = args[:link_opts] || {}
    opts[:path] ||= {}
    opts[:path][:layout] = :modal
    opts["data-target"] = "#modal-main-slot"
    opts["data-toggle"] = "modal"
    text = args[:link_text] || _render_title(args)
    link_to text, opts
  end

  view :modal_slot, tags: :unknown_ok do |args|
    id = "modal-#{args[:modal_id] || 'main-slot'}"
    dialog_args = { class: "modal-dialog" }
    add_class dialog_args, args[:dialog_class]
    wrap_with(:div, class: "modal fade", role: "dialog", id: id) do
      wrap_with(:div, dialog_args) do
        wrap_with :div, class: "modal-content" do
          ""
        end
      end
    end
  end

  view :modal_menu, tags: :unknown_ok do
    popout_params = {}
    popout_params[:view] = params[:view] if params[:view]
    # we probably want to pass on a lot more params than just view,
    # but not all of them
    # (eg we don't want layout, id, controller...)
    wrap_with :div, class: "modal-menu" do
      [
        link_to(glyphicon("remove"),
                path: "", class: "close-modal pull-right close",
                "data-dismiss" => "modal"),
        link_to(glyphicon("new-window"),
                path: popout_params,
                class: "pop-out-modal pull-right close ")
      ]
    end
  end

  view :modal_footer, tags: :unknown_ok do
    button_tag "Close",
               class: "btn-xs close-modal pull-right",
               "data-dismiss" => "modal"
  end
end
