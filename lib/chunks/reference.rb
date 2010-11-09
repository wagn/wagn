module Chunk
  class Reference < Abstract
    attr_reader :card_name, :card
    
    def base_card
      @card
    end
    
    def refcard_name
      @card_name = @card_name.to_absolute(base_card.name)
    end
    
    def refcard 
#      name =  refcard_name.gsub(/_/,' ')   
      @refcard ||= Card.fetch(refcard_name)
    end
      
    def link_text 
      refcard_name
    end

    def card_link
      href = refcard_name
      if (klass = 
        case href
          when /^\//;    'internal-link'
          when /^https?:/; 'external-link'
          when /^mailto:/; 'email-link'
        end)
        if format == :xml
          %{<link class="#{klass}" href="#{href}">#{link_text}</link>}
        else
          %{<a class="#{klass}" href="#{href}">#{link_text}</a>}
        end
      else
        lt = link_text.to_show(href)
        klass = if refcard
          href = href.to_url_key
         'known-card'
        else
          href = CGI.escape(Cardname.escape(href)) unless format == :xml
          'wanted-card'
        end
        if format == :xml
          %{<cardlink class="#{klass}" card="/wagn/#{href}">#{lt}</cardlink>}
        else
          %{<a class="#{klass}" href="/wagn/#{href}">#{lt}</a>}
        end
      end
    end
  end 
end 



