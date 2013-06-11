# -*- encoding : utf-8 -*-



view :core do |args|
  set_search_vars args

  case
  when e = @search[:error]
    Rails.logger.debug " no result? #{e.backtrace}"
    %{No results? #{e.class.to_s} :: #{e.message} :: #{card.content}}
  when @search[:spec][:return] =='count'
    @search[:results].to_s
  else
    _render_card_list args
  end
end

view :card_list do |args|
  @search[:item] ||= :name

  if @search[:results].empty?
    'no results'
  else
    @search[:results].map do |c|
      process_inclusion c, :view=>@search[:item]
    end.join "\n"
  end
end
    
    
    
format :data do
    
  view :card_list do |args|
    @search[:item] ||= :atom
    
    @search[:results].map do |c|
      process_inclusion c, :view=>@search[:item]
    end
  end
end
    
#    format :json
#
#    view :card_list, :type=>:search_type do |args|
#      @search[:item] ||= :name
#
#      if @search[:results].empty?
#        'no results'
#      else
#        # simpler version gives [{'card':{the card stuff}, {'card' ...} vs.
#        # @search[:results].map do |c|  process_inclusion c, :view=>@search[:item] end
#        # This which converts to {'cards':[{the card suff}, {another card stuff} ...]} we may want to support both ...
#        {:cards => @search[:results].map do |c|
#            inc = process_inclusion c, :view=>@search[:item]
#            (!(String===inc) and inc.has_key?(:card)) ? inc[:card] : inc
#          end
#        }
#      end
#    end
    

format :html do
    
  view :card_list do |args|
    @search[:item] ||= :closed

    paging = _optional_render :paging, args

    if @search[:results].empty?
      %{<div class="search-no-results"></div>}
    else
      %{
        #{paging}
        <div class="search-result-list">
          #{
            @search[:results].map do |c|
              %{
                <div class="search-result-item item-#{ @search[:item] }">
                  #{ process_inclusion c, :view=>@search[:item], :size=>args[:size] }
                </div>
              }
            end * "\n"
          }
        </div>
        #{ paging if @search[:results].length > 10 }
      }
    end
  end


  view :closed_content do |args|
    if @depth > 2
      "..."
    else
      search_params[:limit] = 10 #not quite right, but prevents massive invisible lists.  
      # really needs to be a hard high limit but allow for lower ones.

      set_search_vars args        
      @search[:item] = :link unless @search[:item] == :name  #FIXME - probably want other way to specify closed_view ok...
      
      _render_core args.merge( :hide=>'paging' )
    end
  end

  view :editor do |args|
    form.text_area :content, :rows=>10
  end


  view :paging do |args|
    s = card.spec search_params
    offset, limit = s[:offset].to_i, s[:limit].to_i
    return '' if limit < 1
    return '' if offset==0 && limit > offset + @search[:results].length #avoid query if we know there aren't enough results to warrant paging
    total = card.count search_params
    return '' if limit >= total # should only happen if limit exactly equals the total

    @paging_path_args = { :limit => limit, :item  => @search[:item] }
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
end


module Model
  def collection?
    true
  end

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
end



