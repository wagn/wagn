module Chunk
  class Reference < Abstract
    attr_reader :card_name, :card
    
    def base_card
      @card
    end
    
    def refcard_name
      return '' unless @card_name
      @card_name = @card_name.to_absolute(base_card.name)
    end
    
    def refcard 
      @refcard ||= Card.fetch(refcard_name)
    end
      
    def link_text 
      refcard_name
    end

    def render_link
      @content.renderer.build_link(refcard_name, link_text)
    end

  end 
end 



