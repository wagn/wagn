# -*- encoding : utf-8 -*-

format :rss do

  view :show do |args|
  #    render( args[:view] || :feed )
    @xml = Builder::XmlMarkup.new
    render_feed
  end

  # FIXME: integrate this with common XML features when it is added
  view :feed do |args|
    begin
      @xml.instruct! :xml, :version => "1.0"
      @xml.rss :version => "2.0" do
        @xml.channel do
          @xml.title       render_rss_title
          @xml.description render_rss_description
          @xml.link        render_url
          render_rss_item_list
        end
      end
    rescue Exception=>e
      @xml.error "\n\nERROR rendering RSS: #{e.inspect}\n\n #{e.backtrace}"
    end
  end
  
  view :rss_item_list do |args|
    items = if card.type_id == Card::SearchTypeID
      card.item_cards( search_params.merge(:default_limit => 25) )
    else
      [card]
    end
    items.each do |item|
      @xml.item do
        subformat(item).render_rss_item :view_changes=>(card.id==Card::RecentID)  #FIXME! yuck.
      end
    end
  end
  
  
  view :rss_title do |args|
    Card.setting(:title) + " : " + card.name.gsub(/^\*/,'')
  end
  
  view :rss_item do |args|
    @xml.title card.name
    add_name_context
    @xml.description render((args[:view_changes] ? :change : :open_content))
    @xml.pubDate card.revised_at.to_s(:rfc822)  #updated_at fails on virtual cards, because not all to_s's take args (just actual dates)
    @xml.link render_url
    @xml.guid render_url
  end


  view :rss_description do |args| '' end
  view :comment_box     do |args| '' end
  view :menu            do |args| '' end
    
  
  view :open, :titled
  view :content, :core
  view :open_content, :core
  view :closed, :link

end
