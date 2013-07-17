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

    def self.scan_re chunk_types
      prefix_res = chunk_types.map do |chunk_cl|
        cfg = chunk_cl.config
        prefix = cfg[:idx_char] || :default
        @@prefix_cfg[prefix] = cfg
        cfg[:prefix_re]
      end
      /(?:#{prefix_res * '|'})/mo
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

    def format
      @card_params[:format] #||= Card::Format.new(card) 
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
