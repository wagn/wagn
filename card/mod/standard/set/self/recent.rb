ACTS_PER_PAGE = 5

view :title do |args|
  super args.merge(title: "Recent Changes")
end

format :html do
  view :core do |args|
    content_tag(:div, class: "history-slot list-group") do
      [history_header(false), render_recent_acts(args)].join
    end
  end

  view :recent_acts do |args|
    page = params["page"] || 1
    acts = Act.all_viewable.order(id: :desc).page(page).per(ACTS_PER_PAGE)
    render_act_list args.merge(acts: acts, act_context: :absolute)
  end

  def paging
    acts = Act.all_viewable.order(id: :desc).page(page_from_params).per(ACTS_PER_PAGE)
    wrap_with :span, class: "slotter" do
      paginate acts, remote: true, theme: 'twitter-bootstrap-3'
    end
  end
end
