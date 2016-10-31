ACTS_PER_PAGE = 50

view :title do |args|
  super args.merge(title: "Recent Changes")
end

format :html do
  view :core do |args|
    content_tag(:div, class: "history-slot list-group") do
      [history_legend(false), render_recent_acts(args)].join
    end
  end

  view :recent_acts do |args|
    page = params["page"] || 1
    acts = Act.all_viewable.order(id: :desc).page(page).per(ACTS_PER_PAGE)
    render_act_list args.merge(acts: acts, act_context: :absolute)
  end
end
