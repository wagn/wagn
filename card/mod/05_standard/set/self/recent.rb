ACTS_PER_PAGE = 10

view :title do |args|
   super args.merge(title: 'Recent Changes')
end

format :html do
  view :open do |args|
    frame args.merge(body_class: 'history-slot list-group', content: true) do
      [
        history_legend,
        _render_recent_acts
      ]
    end
  end

  view :recent_acts do |args|
    page = params['page'] || 1
    acts = Act.all_viewable.order(acted_at: :desc).page(page).per(ACTS_PER_PAGE)
    acts.map do |act|
      format = act.card.format :html
      format.render_act args.merge(act: act, act_header: :complete)
    end.join
  end
end
