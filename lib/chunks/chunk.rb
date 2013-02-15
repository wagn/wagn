
class Chunks::Abstract
end

require_dependency 'chunks/uri'
require_dependency 'chunks/literal'
require_dependency 'chunks/reference'
require_dependency 'chunks/link'
require_dependency 'chunks/include'

require 'uri/common'

# A chunk is a pattern of text that can be protected
# and interrogated by a renderer. Each Chunk class has a
# +pattern+ that states what sort of text it matches.
# Chunks are initalized by passing in the result of a
# match by its pattern.

module Chunks
  class Abstract
    cattr_accessor :prefix_cfg
    @@prefix_cfg = {}

    def Abstract::scan_re(chunk_types)
      /(?:#{
        chunk_types.map do |chunk_cl|
          cfg = chunk_cl.config
          prefix = cfg[:idx_char] || :default
          @@prefix_cfg[prefix] = cfg
          cfg[:prefix_re]
        end * '|'
      })/mo
    end

    attr_reader :text, :process_chunk

    def initialize match_string, card_params, params
      @text = match_string
      @processed = nil
      @card_params = card_params
      #warn "base initialize ch #{@card_params.inspect}, #{inspect}"
      self
    end
    
    def card
      @card_params[:card]
    end

    def renderer
      @card_params[:renderer] #||= Wagn::Renderer.new(card) 
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
