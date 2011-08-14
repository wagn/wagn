module Chunk
  class Reference < Abstract
    attr_accessor :cardname
    
    def base_card()
      card
    end
    
    def cardname=(name)
      return @cardname=nil unless name
      @cardname = name.to_cardname
    end

    def refcardname()
      #Rails.logger.info "refcardname() #{cardname.inspect}"
      cardname && self.cardname = cardname.to_absolute(base_card.cardname).to_cardname
    end
    
    def refcard()
      @refcard ||= refcardname && Card.fetch(refcardname)
    end

    def link_text()
      refcardname.to_s
    end

    def render_link()
      Rails.logger.debug "rl calls build_link(#{refcardname.inspect}, #{self.link_text.inspect})"
      @content.renderer.build_link(refcardname, self.link_text)
    end

  end 
end 



