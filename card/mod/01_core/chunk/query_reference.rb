# -*- encoding : utf-8 -*-

require_dependency File.expand_path( '../reference', __FILE__ )

module Card::Chunk

  # This should find +Alfred+ in expressions like
  # 1) {"name":"Alfred"}
  # 2a) {"name":["in","Alfred"]}
  # 3a) {"plus_right":["Alfred"]}
  # but not in
  # 2b) "content":"foo", "Alfred":"bar"
  # 3b) {"name":["Alfred", "Toni"]}
  # It's not possible to distinguish between 2a) and 2b) or 3a) and 3b) with a simple regex
  # hence we use a too general regex and check for query keywords after the match
  # which of course means that we don't find references with query keywords as name
  class QueryReference < Reference
    QUERY_KEYWORDS = ::Set.new(
      (
        Card::Query::MODIFIERS.keys                +
        Card::Query::OPERATORS.keys                +
        Card::Query::CardClause::ATTRIBUTES.keys   +
        Card::Query::CardClause::CONJUNCTIONS.keys +
        ['desc', 'asc', 'count']
      ).map(&:to_name)
    )
    word = /\s*([^"]+)\s*/

    # we check for colon, comma or square bracket before a quote
    # OPTIMIZE: instead of comma or square bracket check for operator followed by comma or "plus_right"|"plus_left"|"plus" followed by square bracket
    Card::Chunk.register_class self, {
      :prefix_re => '(?<=[:,\\[])\\s*"',  # we have to use a lookbehind, otherwise
                                                  # if the colon matches it would be
                                                  # identified mistakenly as an URI chunk
      :full_re   => /"([^"]+)"/,
      :idx_char  => '"'
    }

    class << self
      def full_match content, prefix
        match, offset = super(content,prefix)
        if match && !QUERY_KEYWORDS.include?(match[1].to_name)
          [match, offset]
        end
      end
    end

    def interpret match, content
      @name = match[1]
    end

    def process_chunk
      @process_chunk ||= @text
    end

    def inspect
      "<##{self.class}:n[#{@name}] p[#{@process_chunk}] txt:#{@text}>"
    end

    def replace_reference old_name, new_name
      replace_name_reference old_name, new_name
      @text = "\"#{referee_name.to_s}\""
    end
  end
end
