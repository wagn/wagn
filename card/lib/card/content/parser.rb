require_dependency "card/content/chunk"

class Card
  class Content
    # The Content::Parser breaks content strings into an Array of "chunks",
    # each of which may be an instance of a {Chunk} class or a simple String.
    class Parser
      # @param chunk_list [Symbol] name of registered list of chunk classes
      # to be used in parsing
      # @see Card::Chunk.register_list
      # @param content_object [Card::Content]
      def initialize chunk_list, content_object
        @content_object = content_object
        @chunk_list = chunk_list
      end

      # break content string into an array of chunk objects and strings
      # @param content [String]
      # @return [Array]
      def parse content
        @content = content
        @chunks = []
        return @chunks unless content.is_a? String
        @position = @last_position = 0
        @interval_string = ""
        parse_chunks
        @chunks
      end

      private

      def parse_chunks
        prefix_regexp = Chunk.get_prefix_regexp @chunk_list
        match_prefices prefix_regexp
        handle_remainder
      end

      def match_prefices prefix_regexp
        while match_prefix prefix_regexp
          @chunk_class = Chunk.find_class_by_prefix @prefix, @chunk_list
          # get the chunk class from the prefix
          content_slice = @content[@position..-1]
          @match, @offset = @chunk_class.full_match content_slice, @prefix
          # see whether the full chunk actually matches
          # (as opposed to bogus prefix)
          if @match # we have a chunk match
            next if record_chunk
          else # no match.  look at the next character
            @position += 1
          end
          @interval_string += @content[@chunk_start..@position - 1]
          # moving beyond the alleged chunk.
          # append failed string to "nonchunk" string
        end
      end

      def match_prefix prefix_regexp
        prefix_match = @content[@position..-1].match(prefix_regexp)
        if prefix_match
          @prefix = prefix_match[0]
          # prefix of matched chunk
          @chunk_start = prefix_match.begin(0) + @position
          # content index of beginning of chunk
          if prefix_match.begin(0) > 0
            # if matched chunk is not beginning of test string
            @interval_string += @content[@position..@chunk_start - 1]
            # hold onto the non-chunk part of the string
          end
          @position = @chunk_start
          # move scanning position up to beginning of chunk
          true
        end
      end

      def record_chunk
        @position += (@match.end(0) - @offset.to_i)
        # move scanning position up to end of chunk
        if !@chunk_class.context_ok? @content, @chunk_start
          # make sure there aren't contextual reasons for ignoring this chunk
          false
        else
          @chunks << @interval_string unless @interval_string.empty?
          @interval_string = ""
          # add the nonchunk string to the chunk list and
          # reset interval string for next go-round
          @chunks << @chunk_class.new(@match, @content_object)
          # add the chunk to the chunk list
          @last_position = @position
          # note that the end of the chunk was the last place where a
          # chunk was found (so far)
          true
        end
      end

      def handle_remainder
        if @chunks.any? && @last_position < @content.size
          # handle any leftover nonchunk string at the end of content
          @chunks << @content[@last_position..-1]
        end
      end
    end
  end
end
