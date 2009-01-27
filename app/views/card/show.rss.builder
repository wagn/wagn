xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @card.name
    xml.decription "what is this list?"
    xml.link url_for_page(@card.name)
    
    cards = if Card::Search === @card 
      @card.search( :limit => 10 )
      @card.results
    else 
      [@card]
    end
    
    cards.each do |card|
      xml.item do 
        xml.title card.name

        slot = get_slot(card, "main_1", "view", :transclusion_view_overrides => {
          :open => :content,
          :closed => :link
        })
        xml.description slot.render(:content )
        
        xml.pubDate Time.now #card.created_at.to_s(:rfc822)
        xml.link url_for_page(card.name)
      end
    end
  end
end
 