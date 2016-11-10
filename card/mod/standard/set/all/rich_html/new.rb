format :html do
  view :new, perms: :create, tags: :unknown_ok, cache: :never do
    voo.title ||= new_view_title if new_name_prompt?
    voo.show :help
    frame_and_form :create, "main-success" => "REDIRECT" do
      [
        new_view_hidden,
        new_view_name,
        new_view_type,
        _optional_render_content_formgroup,
        _optional_render_new_buttons
      ]
    end
  end

  def new_view_title
    output(
      "New",
      (card.type_name unless card.type_id == Card.default_type_id)
    )
  end

  def new_view_hidden
    target = card.rule(:thanks) || "_self"
    hidden_field_tag "success", target
  end

  # NAME HANDLING

  def new_view_name
    if new_name_prompt?
      new_name_formgroup
    elsif !autoname?
      hidden_field_tag "card[name]", card.name
    end
  end

  def new_name_formgroup
    output _optional_render_name_formgroup,
           hidden_field_tag("name_prompt", true)
  end

  def new_name_prompt?
    voo.visible? :name_formgroup do
      needs_name? || params[:name_prompt]
    end
  end

  def autoname?
    @autoname.nil? ? (@autoname = card.rule_card :autoname).present? : @autoname
  end

  def needs_name?
    card.name.blank? && !autoname?
  end

  # TYPE HANDLING

  def new_view_type
    if new_type_prompt?
      _render_new_type_formgroup
    else
      hidden_field_tag "card[type_id]", card.type_id
    end
  end

  def new_type_prompt?
    voo.visible? :new_type_formgroup do
      !new_type_preset? && new_type_prompt_context? && new_type_permitted?
    end
  end

  def new_type_preset?
    params[:type] || voo.type
  end

  def new_type_prompt_context?
    main? || card.simple? || card.is_template?
  end

  def new_type_permitted?
    Card.new(type_id: card.type_id).ok? :create
  end

  view :new_type_formgroup do
    wrap_type_formgroup do
      type_field class: "type-field live-type-field",
                 href: path(view: :new),
                 "data-remote" => true
    end
  end

  view :new_buttons do
    cancel_path = !main? && path(view: :missing)
    button_formgroup do
      [standard_submit_button, standard_cancel_button(cancel_path)]
    end
  end
end
