# -*- encoding : utf-8 -*-


# A chunk is a pattern of text that can be protected
# and interrogated by a format. Each Chunk class has a
# +pattern+ that states what sort of text it matches.
# Chunks are initalized by passing in the result of a
# match by its pattern.

module Card::Chunk
  mattr_accessor :raw_list, :list_regexp, :prefix_cfg
  @@raw_list, @@list_regexp, @@prefix_cfg = {}, {}, {}
  
  class << self
    def register_list key, list
      raw_list[key] = list
    end
    
    def get_regexp key
      @@list_regexp[key] ||= begin
        chunk_types = raw_list[key].map { |chunkname| const_get chunkname }
        prefix_res = chunk_types.map do |chunk_class|
          cfg = chunk_class.config
          
          prefix = cfg[:idx_char] || :default  # this is gross and needs to be moved out.  
          @@prefix_cfg[prefix] = cfg           # the entire chunk config mechanism needs attention imo - efm
          
          cfg[:prefix_re]
        end
        /(?:#{ prefix_res * '|' })/m
      end
    end  
  end
  
  
  #not sure whether this is best place.  Could really happen almost anywhere (even before chunk classes are loaded).
  register_list :default, [ :URI, :HostURI, :EmailURI, :EscapedLiteral, :Include, :Link ]
  register_list :references,                         [ :EscapedLiteral, :Include, :Link ]

  
  class Abstract
    require 'uri/common'

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
  
  Card.load_chunks
end
