module Chunk
  class Reference < Abstract
    attr_reader :card_name
    
    def base_card()
      card
    end
    
    def card_name=(name) @card_name = name.to_cardname end

    def refcard_name()
      card_name ?  card_name = card_name.to_absolute(base_card.cardname) : ''
    end
    
    def refcard()
      @refcard ||= Card.fetch(refcard_name)
    end

    alias link_text refcard_name

    def render_link()
      @content.renderer.build_link(refcard_name, link_text)
    end

  end 
end 



