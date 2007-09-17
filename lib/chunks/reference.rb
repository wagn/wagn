module Chunk
  class Reference < Abstract
    attr_reader :card_name, :card
    # the referenced card
    def initialize(matchtext, content)
      super
      @card = content.card
    end
    
    def relative?
      @relative
    end
    
    def base_card
      @card
    end
    
    def refcard_name
      (relative? and base_card) ? base_card.name + @card_name : @card_name
    end
    
    def refcard
      @refcard ||= Card.find_by_name( refcard_name.gsub(/_/,' ') )
    end
      
    def link_text 
      refcard_name
    end
    
    protected
      def card_link
        href = CGI.escape(Cardname.escape(refcard_name))
        klass = refcard ? 'known-card' : 'wanted-card'
        %{<a class="#{klass}" href="/wagn/#{href}">#{link_text}</a>}
      rescue Exception=>e
        return "error rendering link"
      end
      
  end    
end 



