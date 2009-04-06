xml.instruct! :xml, :version => "1.0"
xml.card do
  xml.title  System.site_title + " : " + @card.name.gsub(/^\*/,'')

  if Card::Pointer === @card    
    @card.pointees.each do |card|
      xml.item do 
        xml.name card
      end
    end                                               
  else 
    slot = get_slot(card, "main_1", "view")
    xml.description slot.render( :raw_content )
    xml.pubDate card.updated_at.to_s(:rfc822) 
    xml.link card_url(card)
    #xml.guid card_url(card)
  end
end
                         

