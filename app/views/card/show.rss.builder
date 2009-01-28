xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title  System.site_name + " : " + @card.name.gsub(/^\*/,'')
    xml.decription ""
    xml.link url_for_page(@card.name)
    
    cards = if Card::Search === @card 
      @card.search( :limit => 10 )
      @card.results
    else 
      [@card]
    end
    view_changes = (@card.name=='*recent changes')
    
    cards.each do |card|
      xml.item do 
        xml.title card.name
        slot = get_slot(card, "main_1", "view", :transclusion_view_overrides => {
          :open => :rss_titled,
          :content => :expanded_view_content,
          :closed => :link
        })                    
        xml.description slot.render( view_changes ? :rss_change : :expanded_view_content )
        xml.pubDate card.updated_at.to_s(:rfc822) 
        xml.link url_for_page(card.name)
      end
    end
  end
end
 