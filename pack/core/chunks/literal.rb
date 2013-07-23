# -*- encoding : utf-8 -*-

# These are basic chunks that have a pattern and can be protected.
# They are used by rendering process to prevent wiki rendering
# occuring within literal areas such as <code> and <pre> blocks
# and within HTML tags.
module Card::Chunk
  class EscapedLiteral < Abstract
    Card::Chunk.register_class self, {
      :prefix_re => '\\\\(?:\\[\\[|\\{\\{)',
      :rest_re   => { '[' => /^[^\]]*\]\]/, '{' => /^[^\}]*\}\}/ },
      :idx_char  => '\\'
    }

    def interpret match, content, params
      @process_chunk = match.sub(/^\\(.)/, "<span>\\1</span>")
    end
  end

end
