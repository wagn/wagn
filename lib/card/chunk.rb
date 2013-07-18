# -*- encoding : utf-8 -*-


# A chunk is a pattern of text that can be protected
# and interrogated by a format. Each Chunk class has a
# +pattern+ that states what sort of text it matches.
# Chunk are initalized by passing in the result of a
# match by its pattern.

module Card::Chunk
  
  class Abstract
    require 'uri/common'
    
    cattr_accessor :prefix_cfg
    @@prefix_cfg = {}

    def self.parse_regexp chunk_types
      chunk_types.map! { |chunkname| Card::Chunk.const_get chunkname }
      prefix_res = chunk_types.map do |chunk_cl|
        cfg = chunk_cl.config
        prefix = cfg[:idx_char] || :default
        @@prefix_cfg[prefix] = cfg
        cfg[:prefix_re]
      end
      /(?:#{ prefix_res * '|' })/mo
    end

    attr_reader :text, :process_chunk

    def initialize match_string, content, params
      @text = match_string
      @processed = nil
      @content = content
      self
    end
    
    def format
      @content.format
    end
    
    def card
      @content.card
    end

    def to_s
      @process_chunk || @processed || @text
    end

    def inspect
      "<##{self.class}##{to_s}>"
    end

    def as_json(options={})
      @process_chunk || @processed|| "not rendered #{self.class}, #{card and card.name}"
    end
  end
end
