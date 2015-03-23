format do 
  def page_link text, page, current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    options.merge!(:class=>'card-paging-link slotter', :remote => true)
    link_to raw(text), path(@paging_path_args), options
  end
  
  def page_li text, page, current=false, options={}
    css_class = if current
                  'active'
                elsif !page
                  'disabled'
                end
    page ||= 0
    content_tag :li, :class=>css_class do
      page_link text, page, current, options
    end
  end
  
  def previous_page_link page
    page_li '<span aria-hidden="true">&laquo;</span>', page, false, 'aria-label'=>"Previous"
  end
  
  def next_page_link page
    page_li '<span aria-hidden="true">&raquo;</span>', page, false, 'aria-label'=>"Next"
  end
  
  def ellipse_page
    content_tag :li, content_tag(:span, '...')
  end
end

format :html do
  view :paging do |args|
    s = card.query search_params
    offset, limit = s[:offset].to_i, s[:limit].to_i
    return '' if limit < 1
    return '' if offset==0 && limit > offset + search_results.length #avoid query if we know there aren't enough results to warrant paging
    total = card.count search_params
    return '' if limit >= total # should only happen if limit exactly equals the total

    @paging_path_args = { :limit => limit, :item=> inclusion_defaults(card)[:view] }
    @paging_limit = limit

    s[:vars].each { |key, value| @paging_path_args["_#{key}"] = value }

    out = ['<nav><ul class="pagination paging">' ]

    total_pages  = ((total-1) / limit).to_i
    current_page = ( offset   / limit).to_i # should already be integer
    window = 2 # should be configurable
    window_min = current_page - window
    window_max = current_page + window

    previous_page = current_page > 0 ? current_page - 1 : false
    out << previous_page_link(previous_page)
    if window_min > 0
      out << page_li( 1, 0 )
      out << ellipse_page if window_min > 1
    end

    (window_min .. window_max).each do |page|
      next if page < 0 or page > total_pages
      text = page + 1
      out << page_li( text, page, page==current_page ) 
    end

    if total_pages > window_max
      out << ellipse_page if total_pages > window_max + 1
      out << page_li( total_pages + 1, total_pages )
    end

    next_page = current_page < total_pages ? current_page + 1 : false
    out << next_page_link(next_page)

    out << %{</ul></nav>}
    out.join
  end
end
