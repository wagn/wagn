
class Renderer
  view(:raw, :name=>'*recent_change') do
    %{{"sort":"update", "dir":"desc", "view":"change"}}
  end

  view(:raw, :name=>'*search') do
    %{{"match":"_keyword", "sort":"relevance"}}
  end

  view(:raw, :name=>'*broken_link') do
    %{{"link_to":"_none"}}
  end

  view(:raw, :type=>'search') do
    s = paging_params

    instruction =
      case
        when card.name=='*search'
          s[:_keyword] ||= params[:_keyword]
          %{Cards matching keyword: <strong class="keyword">#{params[:_keyword]}</strong>}
          # when cue = card.attribute_card('*cue'); cue
        else; nil
      end

    title =
      case card.name
        when '*search'; 'Search Results' #ENGLISH
        when '*broken links'; 'Cards with Broken Links'
        else; ''
      end

    begin
      card.search( s )
    rescue Exception=>e
      error = e
    end

    s.inspect +
      if card.results.nil?
        %{"#{error.class.to_s}: #{error.message}" <br/>#{ card.content }}
      else 
        view = (item_view || card.spec[:view] || :closed).to_sym
        if card.name=='*recent changes'
          recent_changes_part
        else
          card_list_part
        end
      end
  end

  view(:recent_changes, :type=>'search') do
    cards ||= []
    view  ||= :change

    paging = paging_part
    %{
<h1 class="page-header"><%= @title %></h1>
<div class="card-slot recent-changes">
  <div class="open-content">#{
      paging }#{
      cards_by_day = Hash.new { |h, day| h[day] = [] }
      cards.each do |card|
        #FIXME - tis UGLY, we're getting cached cards, so get the real card to call
        # revised_at on.  the cards should already be there from the search results.
        #- yeah, also seems like this should be some sort of card list option. -efm
        real_card = card.respond_to?(:card) ? card.card : card
        begin
          day = Date.new(real_card.updated_at.year, real_card.updated_at.month, real_card.updated_at.day)
        rescue Exception=>e
          day = Date.today
          card.content = "(error getting date)"
        end
        cards_by_day[day] << card
      end
      cards_by_day.keys.sort.reverse.each do |day| 
        %{
    <h2>#{
        format_date(day, include_time = false) }</h2>
    <div class="search-result-list">#{
         cards_by_day[day].each do |card| %{
      <div class="search-result-item item-#{ view }">#{
           process_inclusion(card, :view=>view) }
      </div>}
         end * ' '}
    </div>#{
         paging }
  </div>
</div>
    }
      end * "\n"
    }}
  end

  view(:card_list, :type=>'search') do
    cards   ||= []
    duplicates ||= []
    context ||= 'default'
    title   ||= ''
    instruction ||= nil  
    view  ||= :closed    
    #  raise("invalid view") unless [:open, :closed, :content, :name, :link, :change].include?(view)

    paging = paging_part

    # now the result string ...
    if !title.empty?
      @title=title
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
      cards.each do |c|
        %{<div class="search-result-item item-#{ view }">#{
        process_inclusion(c, :view=>view) }</div>}
      end.join }
  </div>#{ paging }}
    end
  end

  view(:paging, :type=>'search') do
    s = card.spec
    offset, limit = s[:offset].to_i, s[:limit].to_i
    first,last = offset+1,offset+card.results.length 
    total = card.count
 
    args = params
    args[:limit] = limit

    args[:requested_view] = requested_view 
    args[:item] = item_view || args[:item]
    args[:_keyword] = s[:_keyword] if s[:_keyword]

    %{
<!-- paging -->#{
      if total > limit
        %{
<span class="paging">#{
        if first > 1
          link_to_remote image_tag('prev-page.png'), :update=>id,
            :url=>url_for('card/view', args.merge(:offset=>[offset-limit,0].max)) 
        end}
  <span class="paging-range">#{ first } to #{ last } of #{ total }</span>#{
        if last < total
          link_to_remote image_tag('next-page.png'), :update=>id,
             :url=>url_for('card/view', args.merge(:offset=>last))
        end}
  </span>}
      end}
<!-- /paging -->}
  end

  view(:content, :type=>'search') do
    s = paging_params

    instruction = case
      when card.name=='*search'
        s[:_keyword] ||= params[:_keyword]
        %{Cards matching keyword: <strong class="keyword">#{params[:_keyword]}</strong>}
        # when cue = card.attribute_card('*cue'); cue
      else; nil
      end

    title = case card.name
      when '*search'; 'Search Results' #ENGLISH
      when '*broken links'; 'Cards with Broken Links'
      else; ''
      end

    begin
      spec = card.spec
      card.search( s )
    rescue Exception=>e
      error = e
    end

    s.inspect + card.results.nil? ?
      %{#{error.class.to_s}: #{error.message}<br/>#{card.content}} :
      spec[:return] =='count' ?  card.results : begin
        part = (card.name=='*recent changes') ? 'recent_changes' : 'card_list'
        view = (item_view || card.spec[:view] || :closed).to_sym
        render(part, :cards=>card.results, :instruction=>instruction, :title=>title)
      end
  end

  view(:line, :type=>'search') do
    if depth > 2
      #...
    else
      # FIXME: so not DRY.  cut-n-paste from search/_content
      s = paging_params #params[:s] || {}
      begin
        query_results = card.search( s )
        total = card.count
      rescue Exception=>e
        error = e
        query_results = nil
      end
      if query_results.nil?
        %{"#{error.class.to_s}: #{error.message}"<br/>#{card.content}}
      elsif query_results.length==0
        '<span class="faint">(0)</span>'
      else
        %{<span class="faint">(#{ total })</span>
        <div class="search-result-list">
          #{query_results.each_with_index do |c,index|
            %{<div class="search-result-item">#{'name' == item_view || params[:item] ? c.name : link_to_page( c.name ) }</div>}
          end*"\n"}
        </div>}
      end
    end
  end

  view(:tag_cloud, :type=>'search') do
    cards ||= []
    link_to ||= 'page'  # other options is 'connect'
    tag_cloud = {}
    category_list = %w[1 2 3 4 5]
    droplets = []
    return if cards.empty?

    # this does scaling by rank(X), where X is what we ordered by in wql.
    # if we wanted proportionate to X, we'd need to get X returned as part of
    # the cards, which has implications for wql; namely we'd need to be able to
    # return additional fields.
    cards.reverse.each_with_index do |tag, index|
      tag_cloud[tag] = index
    end

    max, min = 0, 0
    tag_cloud.each_value do |count|
      max = count if count > max
      min = count if count < min
    end

    divisor = ((max - min) / category_list.size) + 1

    droplets = cards.sort_by {|c| c.name.downcase } .map do |card|
      category = category_list[(tag_cloud[card] - min) / divisor]
      options = { :class=>"cloud-#{category}" }
      WagnHelper::Droplet.new(card.name, options)
    end
    %{
<div class="cloud">#{
      for droplet in droplets 
        flexlink link_to, droplet.name,  droplet.link_options
      end * "\n" }
</div>}
  end
end
