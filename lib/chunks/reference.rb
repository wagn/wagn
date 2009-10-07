module Chunk
  class Reference < Abstract
    attr_reader :card_name, :card
    
    def base_card
      @card
    end
    
    def refcard_name
      @card_name.to_absolute(base_card.name)
    end
    
    def refcard 
      name =  refcard_name.gsub(/_/,' ')   
      @refcard ||= (Card.find_by_name( name ) || Card.find_virtual( name ))
    end
      
    def link_text 
      refcard_name
    end

=begin  
#I don't think this is begin used. 
    protected
      def card_link
        href = CGI.escape(Cardname.escape(refcard_name))
        klass = refcard ? 'known-card' : 'wanted-card'
        %{<a class="#{klass}" href="/wagn/#{href}">#{link_text}</a>}
      rescue Exception=>e
        return "error rendering link"
      end
=end
      
  end 
   
end 



