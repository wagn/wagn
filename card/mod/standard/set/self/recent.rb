ACTS_PER_PAGE = 50

view :title do
  voo.title = "Recent Changes"
  super()
end

format :html do
  view :core do
    bs_layout container: true, fluid: true do
      row md: [12, 12], lg: [6, 6] do
        col action_legend(false)
        col content_legend, class: "text-right"
      end
      row 12 do
        html _render_recent_acts(args)
      end
      row 12 do
        col paging
      end
g|
    end
  en  view :recent_acts, cache: :never do
    acts = Act.all_viewable.order(id: :desc)
              .page(page_from_params).per(ACTS_PER_PAGE)
    render_act_list acts: acts, act_context: :absolute
  end

  def paging
    acts = Act.all_viewable.order(id: :desc).page(page_from_params).per(ACTS_PER_PAGE)
    wrap_with :span, class: "slotter" do
      paginate acts, remote: true, theme: 'twitter-bootstrap-3'
    end
  end
end
