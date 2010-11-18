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
        # matched the [[..(|..)?]]  case, 1=first slot, 3=sencond
        @link_text = match_data[  match_data[2] ? 3 : 1 ]
      else
        # matched [..][..] case, 4=first slot, 5=second
        @link_text, @card_name = match_data[4], match_data[5] #.gsub(/_/,' ')
      end
    end

    def unmask_text
      @unmask_text ||= card_link
    end
    
    def revert
      @text = @card_name == @link_text ? "[[#{@card_name}]]" : "[[#{@card_name}|#{@link_text}]]"
      super
    end

  end
end
