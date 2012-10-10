module Chunk
  class Reference < Abstract
    attr_accessor :cardname
    
    def cardname=(name)
      return @cardname=nil unless name
      @cardname = name.to_cardname
    end

    def refcardname()
      cardname && self.cardname = cardname.to_absolute(card.cardname).to_cardname
    end
    
    def refcard()
      @refcard ||= refcardname && Card.fetch(refcardname)
    end

    def link_text()
      refcardname.to_s
    end

    def render_link()
      @content.renderer.build_link(refcardname, self.link_text)
    end

  end 
end 



