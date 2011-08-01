module Chunk
  class Reference < Abstract
    attr_reader :cardname
    
    def base_card()
      card
    end
    
    def cardname=(name) @cardname = name.to_cardname end

    def refcardname()
      cardname && cardname = cardname._to_absolute(base_card.cardname)
    end
    
    def refcard()
      @refcard ||= refcardname && Card.fetch(refcardname)
    end

    def link_text()
      refcardname.to_s
    end

    def render_link()
      @content.renderer.build_link(refcardname.to_s, link_text)
    end

  end 
end 



