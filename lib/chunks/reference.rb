module Chunk
  class Reference < Abstract
    attr_reader :card_name, :card
    
    class << self
      def standard_card_link(name)
        card_link(name, name, Card.fetch(name))
      end
      
      def card_link(name, text, known)
        href, klass = known ? 
          [name.to_url_key                   , 'known-card' ] : 
          [CGI.escape(Cardname.escape(name)) , 'wanted-card']
        %{<a class="#{klass}" href="/wagn/#{href}">#{text}</a>}
      end
    end

    def base_card
      @card
    end
    
    def refcard_name
      return '' unless @card_name
      @card_name = @card_name.to_absolute(base_card.name)
    end
    
    def refcard 
#      name =  refcard_name.gsub(/_/,' ')   
      @refcard ||= Card.fetch(refcard_name)
    end
      
    def link_text 
      refcard_name
    end


    def html_link
      href = refcard_name
      if (klass = 
        case href
          when /^\//;    'internal-link'
          when /^https?:/; 'external-link'
          when /^mailto:/; 'email-link'
        end)
        lt = link_text()
Rails.logger.info "html_link #{href} LT:#{lt}"
        %{<a class="#{klass}" href="#{href}">#{lt}</a>}
      else
        self.class.card_link(href, link_text.to_show(href), refcard)
      end
    end
  end 
end 



