xml.instruct! :xml, :version => "1.0"   
xml.kml do
  xml.Document do
    cards = if Card::Search === @card    
          @card.search( :limit => 25, :_keyword=>params[:_keyword] )
          @card.results
        else 
          [@card]
        end
        
    cards.each do |card|
      if geocard = CachedCard.get_real("#{card.name}+*geocode")    
        xml.Placemark do
          xml.name card.name  
          content_card = CachedCard.get_real("#{card.name}+*geodescription") || card
          slot = get_slot(content_card, "main_1", "view")
          xml.description slot.render( :content )
          xml.Point do
            xml.coordinates geocard.content
          end
        end
      end
    end
  end
end
