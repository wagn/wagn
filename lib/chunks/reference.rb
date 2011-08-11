module Chunk
  class Reference < Abstract
    attr_accessor :cardname
    
    def base_card()
      card
    end
    
    def cardname=(name)
      return @cardname=nil unless name
      r=@cardname = name.to_cardname
      Rails.logger.info "cardname=(#{name.inspect}) #{r.inspect}"; r
    end

    def refcardname()
      Rails.logger.info "refcardname() #{cardname.inspect}"
      r=cardname && cardname._to_absolute(base_card.cardname).to_cardname
      Rails.logger.info "refcardname() #{cardname} > #{r.inspect}"; r
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



