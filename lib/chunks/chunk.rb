
class Chunks::Abstract
end

require_dependency 'chunks/uri'
require_dependency 'chunks/literal'
require_dependency 'chunks/reference'
require_dependency 'chunks/link'
require_dependency 'chunks/include'

require_dependency 'uri/common'

# A chunk is a pattern of text that can be protected
# and interrogated by a renderer. Each Chunk class has a
# +pattern+ that states what sort of text it matches.
# Chunks are initalized by passing in the result of a
# match by its pattern.

module Chunks
  class Abstract
    def Abstract::re_class(index)
      @@paren_range.each do |chunk_class, range|
        if range.cover? index
          return chunk_class, range
        end
      end
      raise "not found #{index}, #{@@paren_range.inspect}"
    end

    def Abstract::unmask_re(chunk_types)
      @@paren_range = {}
      pindex = 0
      chunk_pattern = chunk_types.map do |ch_class|
        pend = pindex + ch_class.groups
        @@paren_range[ch_class] = pindex..pend-1
        pindex = pend
        ch_class.pattern
      end * '|'
      /(.*?)(#{chunk_pattern})/m
    end

    attr_reader :text, :unmask_text

    def initialize match_string, card_params, params
      @text = match_string
      @unmask_render = nil
      @card_params = card_params
    end
    def renderer()           @card_params[:renderer] end
    def card()               @card_params[:card]     end
    def avoid_autolinking?() false                   end

    def to_s
      @unmask_text || @unmask_render|| @text
    end

    def as_json(options={})
      @unmask_text || @unmask_render|| "not rendered #{self.class}, #{card and card.name}"
    end
  end
end
