ACTS_PER_PAGE = 50

view :title do
  voo.title = "Recent Changes"
  super()
end

format :html do
  view :core do
    wrap_with :div, class: "history-slot list-group" do
      [history_legend, render_recent_acts]
    end
  end

  view :recent_acts do
    page = params["page"] || 1
    acts = Act.all_viewable.order(id: :desc).page(page).per(ACTS_PER_PAGE)
    acts.map do |act|
      if (act_card = act.card)
        act_card.format(:html).render_act act: act, act_context: :absolute
      else
        Rails.logger.info "bad data, act: #{act}"
        ""
      end
    end.join
  end
end
