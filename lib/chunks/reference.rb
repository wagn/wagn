module Chunk
  class Reference < Abstract
    attr_reader :card_name, :card
    # the referenced card
        
    def initialize(matchtext, content)
      super
      @card = content.card
    end
    
=begin
    def relative?
      @relative
    end
=end
    
    def base_card
      @card
    end
    
    def refcard_name
      @card_name.to_absolute(base_card.name)
#      (relative? and base_card) ? base_card.name + @card_name : @card_name
    end
    
    def refcard 
      name =  refcard_name.gsub(/_/,' ')   
      @refcard ||= (Card.find_by_name( name ) || Card.find_phantom( name ))
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



