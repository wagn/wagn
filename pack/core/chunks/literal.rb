# -*- encoding : utf-8 -*-

# These are basic chunks that have a pattern and can be protected.
# They are used by rendering process to prevent wiki rendering
# occuring within literal areas such as <code> and <pre> blocks
# and within HTML tags.
module Card::Chunk
  class EscapedLiteral < Abstract
    FULL_RE = { '[' => /^\\\[\[[^\]]*\]\]/, '{' => /^\\\{\{[^\}]*\}\}/ }
    Card::Chunk.register_class self, {
      :prefix_re => '\\\\(?:\\[\\[|\\{\\{)',
      :idx_char  => '\\'
    }

    def self.full_re prefix
      re = FULL_RE[ prefix[1,1] ]
    end

    def interpret match, content
      @process_chunk = match[0].sub(/^\\(.)/, "<span>\\1</span>")
    end
  end

end
