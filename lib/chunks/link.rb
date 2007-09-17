module Chunk  
  class Link < Reference
    attr_accessor :link_text, :link_type, :card_name
    
#    unless defined? WIKI_LINK 
      word = /\s*((#{"\\"+JOINT})?[^\]]+)\s*/
      WIKI_LINK = /\[\[#{word}\]\]|\[#{word}\]\[#{word}\]/
#    end    

    def self.pattern() WIKI_LINK end

    def initialize(match_data, content)
      super
      @link_type = :show
      if match_data[1] 
        # matched the [[..]]  case
        @link_text = @card_name = match_data[1] #.gsub(/_/,' ')
      else
        # matched [..][..] case, 3=first slot, 5=second
        @link_text = match_data[3]
        @card_name = match_data[5]  #.gsub(/_/,' ')
      end       
      # FIXME
      @relative = match_data[2] || match_data[6] || false
    end

    def unmask_text
      @unmask_text ||= card_link
    end
    
    def revert
      @text = @card_name == @link_text ? "[[#{@card_name}]]" : "[#{@link_text}][#{@card_name}]"
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
          href = '/wagn/' + CGI.escape(Cardname.escape(href))
          refcard ? 'known-card' : 'wanted-card'
        end
      %{<a class="#{klass}" href="#{href}">#{link_text}</a>}
    end

  end
end
