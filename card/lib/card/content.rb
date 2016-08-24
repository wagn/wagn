# -*- encoding : utf-8 -*-

require_dependency "card/content/chunk"
require_dependency "card/content/parser"
require_dependency "card/content/clean"
require_dependency "card/content/truncate"

class Card
  # Content objects support the parsing of content strings into arrays that
  # contain semantically meaningful "chunks" like nests, links, urls, etc.
  #
  # Each chunk has an object whose class inherits from {Card::Chunk::Abstract}
  #
  class Content < SimpleDelegator
    extend Card::Content::Clean
    extend Card::Content::Truncate

    attr_reader :revision, :format, :chunks, :opts

    # initialization parses String, detects chunks
    # @param content [String]
    # @param format_or_card [Card::Format or Card]
    # @param opts [Hash]
    # @option opts [Symbol] :chunk_list - name of registered list of chunk
    # classes to be used in parsing
    def initialize content, format_or_card, opts={}
      @format = resolve_format format_or_card
      opts ||= {}
      chunk_list = opts[:chunk_list] || @format.chunk_list
      @chunks = Parser.new(chunk_list, self).parse(content)
      super(@chunks.any? ? @chunks : content)
    end

    # Content must be associated with a Format object, which in turn must be
    # associated with a Card
    # @return [Card]
    def card
      @format.card
    end

    # Find all chunks of a given type
    # @param chunk_type [Chunk Class]
    # @return [Array of Chunk instances]
    def find_chunks chunk_type
      each_chunk.select { |chunk| chunk.is_a?(chunk_type) }
    end

    # sends &block to #process_chunk on each Chunk object
    def process_each_chunk &block
      each_chunk { |chunk| chunk.process_chunk(&block) }
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

    # convert content to String.
    # the common cases here are that either
    #
    # - (a) content is already a String, or
    # - (b) it's an Array that needs to be iterated over and converted into a
    # a string by running to_s on each item.
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

    private

    def resolve_format format_or_card
      if format_or_card.is_a?(Card)
        Format.new format_or_card, format: nil
      else
        format_or_card
      end
    end
  end
end
