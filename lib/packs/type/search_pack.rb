class Wagn::Renderer
  define_view(:core, :type=>'search') do |args|
    error=nil
    results = begin
      card.item_cards( search_params )
    rescue Exception=>e
      error = e; nil
    end

    case
    when results.nil?
      Rails.logger.debug error.backtrace
      %{No results? #{error.class.to_s}: #{error&&error.message}<br/>#{card.content}}
    when card.spec[:return] =='count'
      results.to_s
    else
      render('card_list', :results=>results)
    end
  end
  
  define_view(:editor, :type=>'search') do |args|
    form.text_area :content, :rows=>10
  end

  define_view(:closed_content, :type=>'search') do |args|
    return "..." if @depth > 2
    results= begin
      card.item_cards( search_params )
    rescue Exception=>e
      error = e; nil
    end

    if results.nil?
      %{"#{error.class.to_s}: #{error.message}"<br/>#{card.content}}
    elsif card.spec[:return] =='count'
      results.to_s
    elsif results.length==0
      '<span class="faint">(0)</span>'
    else
      %{<span class="faint">(#{ card.count })</span>
      <div class="search-result-list">
        #{results.map do |c|
          %{<div class="search-result-item">#{@item_view == 'name' ? c.name : link_to_page( c.name ) }</div>}
        end*"\n"}
      </div>}
    end
  end


  define_view(:card_list, :type=>'search') do |args|
    cards = args[:results]
    @item_view ||= (card.spec[:view]) || :closed

    instruction, title = nil,nil
    if card.name=='*search' && search_params[:vars] && keyword=search_params[:vars][:keyword]
      instruction = %{Cards matching keyword: <strong class="keyword">#{keyword}</strong>} #ENGLISH
      title = 'Search Results' #ENGLISH
    end

    paging = render(:paging, :results=>cards)

    # now the result string ...
    if title
      %{<h1 class="page-header">#{ title }</h1>}
    else '' end +
    if instruction; %{
<div class="instruction">
    <p>#{ instruction }</p>
  </div>}
    else '' end +
    if cards.empty?
      %{<div class="search-no-results"></div>}
    else %{#{paging}
  <div class="search-result-list"> #{
      cards.map do |c|
        %{<div class="search-result-item item-#{ @item_view }">#{
        process_inclusion(c, :view=>@item_view) }</div>}
      end.join }
  </div>#{ paging }}
    end
  end




  define_view(:card_list, :name=>'*recent') do |args|
    cards = args[:results]
    @item_view ||= (card.spec[:view]) || :change

    cards_by_day = Hash.new { |h, day| h[day] = [] }
    cards.each do |card|
      begin
        stamp = card.updated_at
        day = Date.new(stamp.year, stamp.month, stamp.day)
      rescue Exception=>e
        day = Date.today
        card.content = "(error getting date)"
      end
      cards_by_day[day] << card
    end

    paging = render(:paging, :results=>cards)
%{<h1 class="page-header">Recent Changes</h1>
<div class="open-view recent-changes">
  <div class="open-content">
    #{ paging }
  } +
    cards_by_day.keys.sort.reverse.map do |day| 
      
%{  <h2>#{format_date(day, include_time = false) }</h2>
    <div class="search-result-list">} +
         cards_by_day[day].map do |card| %{
      <div class="search-result-item item-#{ @item_view }">
           #{process_inclusion(card, :view=>@item_view) }
      </div>}
         end.join(' ') + %{
    </div>
    } end.join("\n") + %{    
      #{ paging }
  </div>
</div>
}
  end



  define_view(:paging, :type=>'search') do |args|
    results = args[:results]
    s = card.spec(search_params)
    offset, limit = s[:offset].to_i, s[:limit].to_i
    first, last = offset+1, offset+results.length 
    total = card.count(search_params)
 
    path_args = { :limit => limit, :item  => ( @item_view || args[:item] ) }
    s[:vars].each { |key, value| path_args["_#{key}"] = value }

    out = []
    if total > limit
      out << '<span class="paging">'

      if first > 1
        path_args[:offset] = [offset-limit,0].max
        out << link_to( image_tag('prev-page.png'), path(:view, path_args),
          :class=>'card-paging-link slotter', :remote => true )
      end
      out << %{<span class="paging-range">#{ first } to #{ last } of #{ total }</span>}

      if last < total
        path_args[:offset] = last
        out << link_to( image_tag('next-page.png'), path(:view, path_args),
          :class=>'card-paging-link slotter', :remote => true ) 
      end
      
      out << '</span>'
    end
    out.join
  end

  def paging_params
    if ajax_call? && @depth > 0
      {:default_limit=>20}  #important that paging calls not pass variables to included searches
    else
      @paging_params ||= begin
        s = {}
        if p = root.params
          [:offset,:limit,:vars].each{ |key| s[key] = p[key] }
        end
        s[:offset] = s[:offset] ? s[:offset].to_i : 0
        if s[:limit]
          s[:limit] = s[:limit].to_i
        else
          s.delete(:limit)
          s[:default_limit] = 20 #can be overridden by card value
        end
        s
      end
    end
  end
end
