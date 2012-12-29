require_dependency 'chunks/chunk'

module Chunks
  class Link < Reference
    attr_accessor :link_text, :link_type

#    unless defined? WIKI_LINK
      word = /\s*([^\]\|]+)\s*/
      WIKI_LINK = /\[\[#{word}(\|#{word})?\]\]|\[#{word}\]\[#{word}\]/
#    end

    def self.pattern() WIKI_LINK end

    def initialize(match_data, content)
      super
      link_type = :show
      if name=match_data[1]
        self.cardname = name.to_name
        # matched the [[..(|..)?]]  case, 1=first slot, 3=sencond
        @link_text = match_data[  match_data[2] ? 3 : 1 ]
      else
        # matched [..][..] case, 4=first slot, 5=second
        @link_text, self.cardname = match_data[4], match_data[5].to_name #.gsub(/_/,' ')
      end
      self
    end

    def unmask_text
      @unmask_text ||= render_link
    end

    def revert
      @text = cardname == link_text ? "[[#{cardname.to_s}]]" : "[[#{cardname.to_s}|#{link_text}]]"
      super
    end

  end
end
