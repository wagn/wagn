require_dependency 'chunks/chunk'

# These are basic chunks that have a pattern and can be protected.
# They are used by rendering process to prevent wiki rendering
# occuring within literal areas such as <code> and <pre> blocks
# and within HTML tags.
module Literal
  class AbstractLiteral < Chunks::Abstract
    def initialize match, card_params, params
      super
      @process_chunk = @text
    end
  end

  class Escape < AbstractLiteral
    unless defined? ESCAPE_PATTERN
      ESCAPE_CONFIG = {
        :class     => Literal::Escape,
        :prefix_re => '\\\\(?:\\[\\[|\\{\\{)',
        :rest_re => { '[' => /^[^\]]*\]\]/, '{' => /^[^}]*}}/ },
        :prefix  => '\\'
      }
    end

    def self.config() ESCAPE_CONFIG end

    def initialize match, card_params, params
      super
      @process_chunk = match.sub(/^\\(.)/, "<span>\\1</span>")
      #warn "new literal chunk pc:[#{@process_chunk}] #{inspect} #{match}, cparams:#{card_params.inspect}, params:#{params.inspect}"
      self
    end
  end

end
