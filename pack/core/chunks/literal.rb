# -*- encoding : utf-8 -*-

# These are basic chunks that have a pattern and can be protected.
# They are used by rendering process to prevent wiki rendering
# occuring within literal areas such as <code> and <pre> blocks
# and within HTML tags.
module Card::Chunk
  class EscapedLiteral < Abstract
    ESCAPE_CONFIG = {
      :class     => Card::Chunk::EscapedLiteral,
      :prefix_re => '\\\\(?:\\[\\[|\\{\\{)',
      :rest_re => { '[' => /^[^\]]*\]\]/, '{' => /^[^\}]*\}\}/ },
      :idx_char  => '\\'
    }

    def self.config() ESCAPE_CONFIG end

    def initialize match, card, format, params
      super
      @process_chunk = match.sub(/^\\(.)/, "<span>\\1</span>")
      self
    end
  end

end
