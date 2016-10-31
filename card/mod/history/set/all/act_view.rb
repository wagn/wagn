ACTS_PER_PAGE = Card.config.acts_per_page

format :html do
  def default_act_args args
    act = (args[:act]  ||= Act.find(params["act_id"]))
    args[:act_seq]     ||= params["act_seq"]
    args[:hide_diff]   ||= hide_diff?
    args[:slot_class]  ||= "revision-#{act.id} history-slot list-group-item"
    args[:action_view] ||= action_view
    act_context args
  end

  view :act_list do |args|
    acts = args.delete :acts
    page = params["page"] || 1
    count = acts.size + 1 - (page.to_i - 1) * ACTS_PER_PAGE
    accordion_group(acts.map do |act|
      if (act_card = act.card)
        count -= 1
        act_card.format(:html).render_act args.merge(act: act, act_seq: count)
      else
        Rails.logger.info "bad data, act: #{act}"
        ""
      end
    end, nil, class: "clear-both")
  end

  view :act do |args|
    act_renderer(args[:act_context]).new(self, args[:act], args).render
  end

  def action_icon action_type, extra_class=nil
    icon = case action_type
           when :create then "plus"
           when :update then "pencil"
           when :delete then "trash"
           when :draft then "wrench"
           end
    glyphicon icon, extra_class
  end

  def action_view
    (params["action_view"] || "summary").to_sym
  end

  def hide_diff?
    params["hide_diff"].to_s.strip == "true"
  end

  private

  def act_renderer context
    if context == :absolute
      Act::ActRenderer::AbsoluteActRenderer
    else
      Act::ActRenderer::RelativeActRenderer
    end
  end

  def act_context args
    args[:act_context] =
      (args[:act_context] || params["act_context"] || :relative).to_sym
  end
end
