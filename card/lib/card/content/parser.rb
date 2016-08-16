require_dependency "card/content/chunk"

class Card
  class Content
    class Parser
      def initialize chunk_list
        @chunk_list = chunk_list
      end
      def parse content, content_object
        chunks = []
        return chunks unless content.is_a? String

        position = last_position = 0
        prefix_regexp = Chunk.get_prefix_regexp @chunk_list
        interval_string = ""

        while (prefix_match = content[position..-1].match(prefix_regexp))
          prefix = prefix_match[0]
          # prefix of matched chunk
          chunk_start = prefix_match.begin(0) + position
          # content index of beginning of chunk
          if prefix_match.begin(0) > 0
            # if matched chunk is not beginning of test string
            interval_string += content[position..chunk_start - 1]
            # hold onto the non-chunk part of the string
          end

          chunk_class = Chunk.find_class_by_prefix prefix, @chunk_list
          # get the chunk class from the prefix
          match, offset =
            chunk_class.full_match content[chunk_start..-1], prefix
          # see whether the full chunk actually matches
          # (as opposed to bogus prefix)
          context_ok = chunk_class.context_ok? content, chunk_start
          # make sure there aren't contextual reasons for ignoring this chunk
          position = chunk_start
          # move scanning position up to beginning of chunk

          if match
            # we have a chunk match
            position += (match.end(0) - offset.to_i)
            # move scanning position up to end of chunk
            if context_ok
              chunks << interval_string unless interval_string.empty?
              # add the nonchunk string to the chunk list
              chunks << chunk_class.new(match, content_object)
              # add the chunk to the chunk list
              interval_string = ""
              # reset interval string for next go-round
              last_position = position
              # note that the end of the chunk was the last place where a
              # chunk was found (so far)
            end
          else
            position += 1
            # no match.  look at the next character
          end

          next unless !match || !context_ok
          interval_string += content[chunk_start..position - 1]
          # moving beyond the alleged chunk.
          # append failed string to "nonchunk" string
        end

        if chunks.any? && last_position < content.size
          remainder = content[last_position..-1]
          # handle any leftover nonchunk string at the end of content
          chunks << remainder
        end

        chunks
      end
    end
  end
end
