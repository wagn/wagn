module Chunk
  class Reference < Abstract
    attr_reader :card_name, :card
    
    def base_card
      @card
    end
    
    def refcard_name
      @card_name = @card_name.to_absolute(base_card.name)
Rails.logger.info "refcard_name #{base_card.name}:#{@card_name}"; @card_name
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
	lt = link_text()
        %{<a class="#{klass}" href="#{href}">#{lt}</a>}
      else
        lt = link_text.to_show(href)
        klass = if refcard
          href = href.to_url_key
         'known-card'
        else
          href = CGI.escape(Cardname.escape(href))
          'wanted-card'
        end
        %{<a class="#{klass}" href="/wagn/#{href}">#{lt}</a>}
      end
    end
  end 
end 



