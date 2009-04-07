module Chunk  
  class Link < Reference
    attr_accessor :link_text, :link_type, :card_name
    
#    unless defined? WIKI_LINK 
      word = /\s*([^\]\|]+)\s*/
      WIKI_LINK = /\[\[#{word}(\|#{word})?\]\]|\[#{word}\]\[#{word}\]/
#    end    

    def self.pattern() WIKI_LINK end

    def initialize(match_data, content)
      super
      @link_type = :show
      if @card_name = match_data[1] 
        # matched the [[..]]  case
        @link_text = match_data[  match_data[2] ? 3 : 1 ]
      else
        # matched [..][..] case, 3=first slot, 5=second
        @link_text = match_data[4]
        @card_name = match_data[5]  #.gsub(/_/,' ')
      end
      # FIXME
      #@relative = match_data[2] || match_data[6] || false
    end

    def unmask_text
      @unmask_text ||= card_link
    end
    
    def revert
      @text = @card_name == @link_text ? "[[#{@card_name}]]" : "[[#{@card_name}|#{@link_text}]]"
      super
    end

    def card_link
      href = refcard_name
      klass = 
        case href
          when /^\//;    'internal-link'
          when /^https?:/; 'external-link'
          when /^mailto:/; 'email-link'
          else
            @link_text = @link_text.to_show(href)
            if refcard
              href = '/wagn/' + href.to_url_key
              'known-card'
            else
              href = '/wagn/' + CGI.escape(Cardname.escape(href))
              'wanted-card'
            end
        end
      %{<a class="#{klass}" href="#{href}">#{link_text}</a>}
    end

  end
end
