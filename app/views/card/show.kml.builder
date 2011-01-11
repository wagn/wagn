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
      if geocard = Card.fetch("#{card.name}+*geocode", :skip_virtual => true)
        xml.Placemark do
          xml.name card.name  
          content_card = Card.fetch_or_new("#{card.name}+*geodescription") || card
          slot = get_slot(content_card, "main_1", "view")
          xml.description slot.render_content
          xml.Point do                                                  
            # apparently the google API likes them in the opposite order for static maps.
            # since we don't have code in the static maps address, we store them that way.
            xml.coordinates geocard.content.split(',').reverse.join(',')
          end
        end
      end
    end
  end
end
