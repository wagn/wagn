

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
      search_vars[:results].to_s
    when @mode == :template
      render :raw
    else
      _render_card_list args
    end
  end

  view :card_list do |args|
    if search_vars[:results].empty?
      'no results'
    else
      search_vars[:results].map do |c|
        nest c
      end.join "\n"
    end
  end
  
  def search_vars args={}
    
    @search_vars ||= begin
      v = {}
      v[:query] = card.query search_params
      v[:item] = set_inclusion_opts args.merge( :query_view=>v[:query][:view] )
      v[:results]  = card.item_cards search_params  # this is really odd.  the search is called from within the vars???
      v
    rescue =>e
      { :error => e }
    end
  end
  
  def set_inclusion_opts args
    @inclusion_defaults = nil
    @inclusion_opts ||= {}
    @inclusion_opts[:view] = args[:item] || inclusion_opts[:view] || args[:query_view] || default_item_view
    # explicit > inclusion syntax > WQL > inclusion defaults
  end

  



  def page_link text, page
    @paging_path_args[:offset] = page * @paging_limit
    " #{link_to raw(text), path(@paging_path_args), :class=>'card-paging-link slotter', :remote => true} "
  end

end
    
    
format :data do
    
  view :card_list do |args|
    search_vars[:results].map do |c|
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

    if search_vars[:results].empty?
      render_no_search_results(args) 
    else
      %{
        #{paging}
        <div class="search-result-list">
          #{
            search_vars[:results].map do |c|
              %{
                <div class="search-result-item item-#{ inclusion_defaults[:view] }">
                  #{ nest c, :size=>args[:size] }
                </div>
              }
            end * "\n"
          }
        </div>
        #{ paging if search_vars[:results].length > 10 }
      }
    end
  end


  view :closed_content do |args|
    if @depth > self.class.max_depth
      "..."
    else
      search_params[:limit] = [args[:closed_search_limit], Card.config.closed_search_limit].min
      _render_core args.merge( :hide=>'paging', :item=>:link )
      # TODO: if item is queryified to be "name", then that should work.  otherwise use link
    end
  end

  view :editor do |args|
    form.text_area :content, :rows=>5
  end

  view :no_search_results do |args|
    %{<div class="search-no-results"></div>}
  end

  view :paging do |args|
    s = card.query search_params
    offset, limit = s[:offset].to_i, s[:limit].to_i
    return '' if limit < 1
    return '' if offset==0 && limit > offset + search_vars[:results].length #avoid query if we know there aren't enough results to warrant paging
    total = card.count search_params
    return '' if limit >= total # should only happen if limit exactly equals the total

    @paging_path_args = { :limit => limit, :item=> inclusion_defaults[:view] }
    @paging_limit = limit

    s[:vars].each { |key, value| @paging_path_args["_#{key}"] = value }

    out = ['<span class="paging">' ]

    total_pages  = ((total-1) / limit).to_i
    current_page = ( offset   / limit).to_i # should already be integer
    window = 2 # should be configurable
    window_min = current_page - window
    window_max = current_page + window

    if current_page > 0
      out << page_link( '&laquo; prev', current_page - 1 )
    end

    out << %{<span class="paging-numbers">}
    if window_min > 0
      out << page_link( 1, 0 )
      out << '...' if window_min > 1
    end

    (window_min .. window_max).each do |page|
      next if page < 0 or page > total_pages
      text = page + 1
      out <<  ( page==current_page ? text : page_link( text, page ) )
    end

    if total_pages > window_max
      out << '...' if total_pages > window_max + 1
      out << page_link( total_pages + 1, total_pages )
    end
    out << %{</span>}

    if current_page < total_pages
      out << page_link( 'next &raquo;', current_page + 1 )
    end

    out << %{<span class="search-count">(#{total})</span></span>}
    out.join
  end
  
  def default_search_params
    set_default_search_params :default_limit=>20
  end
  
  
end








