# -*- encoding : utf-8 -*-



def item_cards params={}
  s = spec(params)
  raise("OH NO.. no limit") unless s[:limit]
  # forces explicit limiting
  # can be 0 or less to force no limit
  #Rails.logger.debug "search item_cards #{params.inspect}"
  Card.search( s )
end

def item_names params={}
  ## FIXME - this should just alter the spec to have it return name rather than instantiating all the cards!!
  ## (but need to handle prepend/append)
  #Rails.logger.debug "search item_names #{params.inspect}"
  Card.search(spec(params)).map(&:cardname)
end

def item_type
  spec[:type]
end

def count params={}
  Card.count_by_wql spec( params )
end

def spec params={}
  @spec ||= {}
  @spec[params.to_s] ||= get_spec(params.clone)
end

def get_spec params={}
  spec = Account.as_bot do ## why is this a wagn_bot thing?  can't deny search content??
    spec_content = params.delete(:spec) || raw_content
    #warn "get_spec #{name}, #{spec_content}, #{params.inspect}"
    raise("Error in card '#{self.name}':can't run search with empty content") if spec_content.empty?
    JSON.parse( spec_content )
  end
  spec.symbolize_keys!.merge! params.symbolize_keys
  if default_limit = spec.delete(:default_limit) and !spec[:limit]
    spec[:limit] = default_limit
  end
  spec[:context] ||= (cardname.junction? ? cardname.left_name : cardname)
  spec
end




format do

  view :core do |args|
    search_vars args

    case
    when e = search_vars[:error]
      Rails.logger.debug " no result? #{e.backtrace}"
      %{No results? #{e.class.to_s} :: #{e.message} :: #{card.content}}
    when search_vars[:spec][:return] =='count'
      search_vars[:results].to_s
    else
      _render_card_list args
    end
  end

  view :card_list do |args|
    if search_vars[:results].empty?
      'no results'
    else
      search_vars[:results].map do |c|
        process_inclusion c
      end.join "\n"
    end
  end
  
  def search_vars args={}
    @vars[:search] ||= begin
      v = {}
      v[:spec] = card.spec search_params
      v[:item] = set_inclusion_opts args.merge( :spec_view=>v[:spec][:view] )
      v[:results]  = card.item_cards search_params
      v
    rescue Exception=>e
      { :error => e }
    end
  end
  
  def set_inclusion_opts args
    @inclusion_defaults = nil
    @inclusion_opts ||= {}
    @inclusion_opts[:view] = args[:item] || inclusion_opts[:view] || args[:spec_view] || default_item_view
    # explicit > inclusion syntax > WQL > inclusion defaults
  end

  def default_search_params
    { :default_limit=> 100 }
  end

  def search_params
    @vars[:search_params] ||= begin
      p = default_search_params
      p[:vars] ||= {} #vars in params in vars.  yuck!
      if self == @root
        params.each do |key,val|
          case key.to_s
          when '_wql'      ;  p.merge! val
          when /^\_(\w+)$/ ;  p[:vars][$1.to_sym] = val
          end
        end
      end
      p
    end
  end

  def page_link text, page
    @paging_path_args[:offset] = page * @paging_limit  #fixme.  should be @vars?
    " #{link_to raw(text), path(@paging_path_args), :class=>'card-paging-link slotter', :remote => true} "
  end

end
    
    
format :data do
    
  view :card_list do |args|
    search_vars[:results].map do |c|
      process_inclusion c
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
    

format :html do
    
  view :card_list do |args|
    paging = _optional_render :paging, args

    if search_vars[:results].empty?
      %{<div class="search-no-results"></div>}
    else
      %{
        #{paging}
        <div class="search-result-list">
          #{
            search_vars[:results].map do |c|
              %{
                <div class="search-result-item item-#{ inclusion_defaults[:view] }">
                  #{ process_inclusion c, :size=>args[:size] }
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
    if @depth > 2
      "..."
    else
      search_params[:limit] = 10 #not quite right, but prevents massive invisible lists.  
      # really needs to be a hard high limit but allow for lower ones.
      _render_core args.merge( :hide=>'paging', :item=>:link )
      # fixme - if item is specified to be "name", then that should work.  otherwise use link
    end
  end

  view :editor do |args|
    form.text_area :content, :rows=>5
  end


  view :paging do |args|
    s = card.spec search_params
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
    if ajax_call? && @depth > 0
      {:default_limit=>20}  #important that paging calls not pass variables to included searches
    else
      @default_search_params ||= begin
        s = {}
        [:offset,:vars].each{ |key| s[key] = params[key] }
        s[:offset] = s[:offset] ? s[:offset].to_i : 0
        if params[:limit]
          s[:limit] = params[:limit].to_i
        else
          s[:default_limit] = 20 #can be overridden by card value
        end
        s
      end
    end
  end
  
end








