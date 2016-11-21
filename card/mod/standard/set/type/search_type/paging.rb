format :html do
  def page_link text, page, _current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    options[:class] = "card-paging-link slotter"
    options[:remote] = true
    options[:path] = @paging_path_args
    link_to raw(text), options
  end

  def page_li text, page, current=false, options={}
    css_class = if current
                  "active"
                elsif !page
                  "disabled"
                end
    page ||= 0
    wrap_with :li, class: css_class do
      page_link text, page, current, options
    end
  end

  def previous_page_link page
    page_li '<span aria-hidden="true">&laquo;</span>', page, false,
            "aria-label" => "Previous"
  end

  def next_page_link page
    page_li '<span aria-hidden="true">&raquo;</span>', page, false,
            "aria-label" => "Next"
  end

  def ellipse_page
    wrap_with :li, wrap_with(:span, "...")
  end

  view :paging, cache: :never do
    limit, offset, vars = raw_paging_params
    return "" if obviously_no_paging_needed? limit, offset

    total = card.count search_params
    return "" if limit >= total
    # should only happen if limit exactly equals the total

    stash_paging_args_for_links limit, vars
    standard_paging total, limit, offset
  end

  def stash_paging_args_for_links limit, vars
    @paging_path_args = {
      limit: limit, view: voo.home_view, slot: { items: voo.items }
    }
    @paging_limit = limit  # why limit twice?

    vars.each do |key, value|
      @paging_path_args["_#{key}"] = value
    end
  end

  # clear we don't need paging even before running count query
  def obviously_no_paging_needed? limit, offset
    return true if limit < 1 # show unlimited results
    offset.zero? &&          # fewer results than fit in a page
      limit > offset + search_results.length
  end

  def raw_paging_params
    s = card.query search_params
    [s[:limit].to_i, s[:offset].to_i, s[:vars]]
  end

  def standard_paging total, limit, offset
    window = 2 # should be configurable

    out = ['<nav><ul class="pagination paging">']

    total_pages = ((total - 1) / limit).to_i
    current_page = (offset / limit).to_i # should already be integer
    window_min = current_page - window
    window_max = current_page + window

    previous_page = current_page > 0 ? current_page - 1 : false
    out << previous_page_link(previous_page)
    if window_min > 0
      out << page_li(1, 0)
      out << ellipse_page if window_min > 1
    end

    (window_min..window_max).each do |page|
      next if page < 0 || page > total_pages
      text = page + 1
      out << page_li(text, page, page == current_page)
    end

    if total_pages > window_max
      out << ellipse_page if total_pages > window_max + 1
      out << page_li(total_pages + 1, total_pages)
    end

    next_page = current_page < total_pages ? current_page + 1 : false
    out << next_page_link(next_page)

    out << %(</ul></nav>)
    out.join
  end
end
