xml.instruct! :xml, :version => "1.0"

if Card::Pointer === @card    
  xml.list do
    xml.title  System.site_title + " : " + @card.name.gsub(/^\*/,'')
    @card.pointees.each do |card|
      xml.item do 
        xml.name card
      end
    end
  end
else 
  xml.card do
    xml.title System.site_title + " : " + @card.name.gsub(/^\*/,'')
    slot = get_slot(card, "main_1", "view")
    xml.name card.name
    xml.key card.key
    xml.revision card.current_revision.id
    xml.description slot.render( :raw_content )
    xml.date card.updated_at.to_s(:rfc822) 
    xml.link card_url(card)
    #xml.guid card_url(card)
  end
end
