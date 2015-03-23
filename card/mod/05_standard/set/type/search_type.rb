

def item_cards params={}
  s = query(params)
  raise("OH NO.. no limit") unless s[:limit]
  # forces explicit limiting
  # can be 0 or less to force no limit
  Card.search( s )
end

def item_names params={}
  ## FIXME - this should just alter the query to have it return name rather than instantiating all the cards!!
  ## (but need to handle prepend/append)
  Card.search(query(params)).map(&:cardname)
end

def item_type
  query[:type]
end

def count params={}
  Card.count_by_wql query( params )
end

def query params={}
  @query ||= {}
  @query[params.to_s] ||= get_query(params.clone)
end

def get_query params={}
  query = Auth.as_bot do ## why is this a wagn_bot thing?  can't deny search content??
    query_content = params.delete(:query) || raw_content
    #warn "get_query #{name}, #{query_content}, #{params.inspect}"
    raise("Error in card '#{self.name}':can't run search with empty content") if query_content.empty?
    String === query_content ? JSON.parse( query_content ) : query_content
  end
  query.symbolize_keys!.merge! params.symbolize_keys
  if default_limit = query.delete(:default_limit) and !query[:limit]
    query[:limit] = default_limit
  end
  query[:context] ||= (cardname.junction? ? cardname.left_name : cardname)
  query
end




format do

  view :core do |args|
    search_vars args

    case
    when e = search_vars[:error]
      %{#{e.class.to_s} :: #{e.message} :: #{card.raw_content}}
    when search_vars[:query][:return] =='count'
      search_results.to_s
    when @mode == :template
      render :raw
    else
      _render_card_list args
    end
  end

  view :card_list do |args|
    if search_results.empty?
      'no results'
    else
      search_results.map do |c|
        nest c
      end.join "\n"
    end
  end
  
  def search_vars args={}
    @search_vars ||=
      begin
        v = {}
        v[:query] = card.query(search_params)
        v[:item]  = set_inclusion_opts args.merge( :query_view=>v[:query][:view] )
        v
      rescue =>e
        { :error => e }
      end
  end

  def search_results
    @search_results ||=
      begin
        card.item_cards search_params
      rescue => e
        { :error => e}
      end
  end
  
  def set_inclusion_opts args
    @inclusion_defaults = nil
    @inclusion_opts ||= {}
    @inclusion_opts[:view] = args[:item] || inclusion_opts[:view] || args[:query_view] || default_item_view
    # explicit > inclusion syntax > WQL > inclusion defaults
  end

  

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
    
    
format :data do
    
  view :card_list do |args|
    search_results.map do |c|
      nest c
    end
  end
end
  
format :csv do
  view :card_list do |args|
    items = super args
    if @depth == 0
      render_csv_title_row + items
    else
      items
    end
  end
end
    
format :json do
  def default_search_params
    set_default_search_params :default_limit => 0
  end
end

format :html do
    
  view :card_list do |args|
    paging = _optional_render :paging, args

    if search_results.empty?
      render_no_search_results(args) 
    else
      results =
        search_results.map do |c|
          item_view = inclusion_defaults(c)[:view]
          %{
            <div class="search-result-item item-#{ item_view }">
              #{nest(c, :size=>args[:size], :view=>item_view)}
            </div>
          }
        end.join "\n"
        
      %{
        #{ paging }
        <div class="search-result-list">
          #{ results }
        </div>
        #{ paging if search_results.length > 10 }
      }
    end
  end


  view :closed_content do |args|
    if @depth > self.class.max_depth
      "..."
    else
      search_limit = args[:closed_search_limit]
      search_params[:limit] = search_limit && search_limit < Card.config.closed_search_limit ?
                                search_limit : Card.config.closed_search_limit
      _render_core args.merge( :hide=>'paging', :item=>:link )
      # TODO: if item is queryified to be "name", then that should work.  otherwise use link
    end
  end

  view :editor do |args|
    text_area :content, :rows=>5, "data-card-type-code"=>card.type_code
  end

  view :no_search_results do |args|
    %{<div class="search-no-results"></div>}
  end

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
  
  def default_search_params
    set_default_search_params :default_limit=>20
  end
  
end


