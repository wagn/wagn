# -*- encoding : utf-8 -*-

require_dependency "card/content/chunk"
require_dependency "card/content/parser"
require_dependency "card/content/clean"


class Card
  class Content < SimpleDelegator
    extend Card::Content::Clean
    attr_reader :revision, :format, :chunks, :opts

    def initialize content, format_or_card, opts={}
      @format =
        if format_or_card.is_a?(Card)
          Format.new format_or_card, format: nil
        else
          format_or_card
        end
      @opts = opts || {}

      @chunks = Parser.new(chunk_list, self).parse(content)
      super(@chunks.any? ? @chunks : content)
    end

    def card
      format.card
    end

    def chunk_list
      @opts[:chunk_list] || @format.chunk_list
    end

    def to_s
      case __getobj__
      when Array    then map(&:to_s) * ""
      when String   then __getobj__
      when NilClass then "" # raise "Nil Card::Content"
      else               __getobj__.to_s
      end
    end

    def inspect
      "<#{__getobj__.class}:#{card}:#{self}>"
    end

    def each_chunk
      return enum_for(:each_chunk) unless block_given?

      iterator =
        case __getobj__
        when Hash   then :each_value
        when Array  then :each
        when String then return # no chunks
        else
          Rails.logger.warn "unrecognized type for #each_chunk: " \
                            " #{self.class} #{__getobj__.class}"
          return
        end
      send(iterator) { |item| yield item if item.is_a?(Chunk::Abstract) }
    end

    def find_chunks chunk_type
      each_chunk.select { |chunk| chunk.is_a?(chunk_type) }
    end

    def process_each_chunk &block
      each_chunk { |chunk| chunk.process_chunk(&block) }
      self
    end
  end
end
