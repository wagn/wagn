format do
  def limit
    default_limit
  end

  def offset
    return 0 unless Env.params[:offset].present?
    Env.params[:offset].to_i
  end

  def search_with_params args={}
    card.item_names(args)
  end

  def count_with_params args={}
    card.item_names(args).count
  end
end

format :html do
  def with_paging path_args={}
    paging_path_args path_args
    output [yield, _optional_render_paging]
  end

  view :paging, cache: :never do
    return "" unless paging_needed?
    <<-HTML
      <nav>
        <ul class="pagination paging">
          #{paging_links.join}
        </ul>
      </nav>
    HTML
  end

  def paging_links
    total_pages = ((count_with_params - 1) / limit).to_i
    current_page = (offset / limit).to_i
    PagingLinks.new(total_pages, current_page)
               .build do |text, page, status, options|
      page_link_li text, page, status, options
    end
  end

  # First page is 0 (not 1)
  def page_link_li text, page, status, options={}
    wrap_with :li, class: status do
      page_link text, page, options
    end
  end

  def page_link text, page, options
    return text unless page
    options.merge! class: "card-paging-link slotter",
                   remote: true,
                   path: paging_path_args(offset: page * limit)
    link_to raw(text), options
  end

  def paging_path_args local_args={}
    @paging_path_args ||= {
      limit: limit,
      view: paging_view,
      slot: voo.slot_options
    }.merge(extra_paging_path_args)
    @paging_path_args.merge local_args
  end

  def paging_view
    (voo && voo.home_view) || :content
  end

  def extra_paging_path_args
    {}
  end

  def paging_needed?
    return false if limit < 1
    return false if fewer_results_than_limit? # avoid extra count search
    # count search result instead
    limit < count_with_params
  end

  # clear we don't need paging even before running count query
  def fewer_results_than_limit?
    return false unless offset.zero?
    limit > offset + search_with_params.length
  end
end
