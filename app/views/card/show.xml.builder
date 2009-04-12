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
    slot = get_slot(card, "main_1", "view", :transclusion_view_overrides => {
          :open => :xml,
          :content => :xml_content,
          :closed => :name,
          :open_missing => :name,
        })
    xml.name card.name
    xml.type card.type
    xml.key card.key
    xml.revision card.current_revision.id
    xml.rawcontent slot.render( :raw_content )
    xml.content do
      xml << slot.render_xml( :xml_expanded )
    end
    #xml.description slot.render( :expanded_view_content )
    xml.date card.updated_at.to_s(:rfc822) 
    xml.link card_url(card)
    #xml.guid card_url(card)
  end
end
