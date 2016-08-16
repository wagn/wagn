ACTS_PER_PAGE = 50

view :title do |args|
  super args.merge(title: "Recent Changes")
end

format :html do
  view :core do |args|
    content_tag(:div, class: "history-slot list-group") do
      [history_legend, render_recent_acts(args)].join
    end
  end

  view :recent_acts do |args|
    page = params["page"] || 1
    acts = Act.all_viewable.order(id: :desc).page(page).per(ACTS_PER_PAGE)
    acts.map do |act|
      if (act_card = act.card)
        format = act_card.format :html
        format.render_act args.merge(act: act, act_context: :absolute)
      else
        Rails.logger.info "bad data, act: #{act}"
        ""
      end
    end.join
  end
end
