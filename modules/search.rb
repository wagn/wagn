
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
    s = slot.paging_params

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
        view = (slot.item_view || card.spec[:view] || :closed).to_sym
        if card.name=='*recent changes'
          recent_changes_part
        else
          card_list_part
        end
      end
  end

  def recent_changes_part
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
           slot.process_inclusion(card, :view=>view) }
      </div>}
         end.join}
    </div>}
      end.join}#{
      paging }
  </div>
</div>
  } end

  def card_list_part 
    # partial => 'card_list'
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
        slot.process_inclusion(c, :view=>view) }</div>}
      end.join }
  </div>#{ paging }}
    end
  end

  def paging_part
    s = card.spec
    offset, limit = s[:offset].to_i, s[:limit].to_i
    first,last = offset+1,offset+card.results.length 
    total = card.count
 
    args = slot.params
    args[:limit] = limit

    args[:requested_view] = slot.requested_view 
    args[:item] = slot.item_view || args[:item]
    args[:_keyword] = s[:_keyword] if s[:_keyword]

    %{
<!-- paging -->#{
      if total > limit
        %{
<span class="paging">#{
        if first > 1
          link_to_remote image_tag('prev-page.png'), :update=>slot.id,
            :url=>slot.url_for('card/view', args.merge(:offset=>[offset-limit,0].max)) 
        end}
  <span class="paging-range">#{ first } to #{ last } of #{ total }</span>#{
        if last < total
          link_to_remote image_tag('next-page.png'), :update=>slot.id,
             :url=>slot.url_for('card/view', args.merge(:offset=>last))
        end}
  </span>}
      end}
<!-- /paging -->}
  end
end
