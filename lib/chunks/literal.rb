require 'chunks/chunk'

# These are basic chunks that have a pattern and can be protected.
# They are used by rendering process to prevent wiki rendering
# occuring within literal areas such as <code> and <pre> blocks
# and within HTML tags.
module Literal
  class AbstractLiteral < Chunk::Abstract
    def initialize(match_data, content)
      super
      @unmask_text = @text
    end
  end

  # A literal chunk that protects 'code' and 'pre' tags from wiki rendering.
  class Pre < AbstractLiteral
#    unless defined? PRE_PATTERN
      PRE_PATTERN = /\/\*(.*?)\*\//
#    end
    def self.pattern() PRE_PATTERN end

    def initialize(match_data, content)
      super
#      warn "LITERALLY!!"
      @unmask_text = "<code>#{match_data[1]}</code>"
    end


#    unless defined? PRE_BLOCKS
#      PRE_BLOCKS = "a|pre|code"
#      PRE_PATTERN = Regexp.new('<('+PRE_BLOCKS+')\b[^>]*?>.*?</\1>', Regexp::MULTILINE)
#    end
  end 

  # A literal chunk that protects HTML tags from wiki rendering.
  class Tags < AbstractLiteral
    unless defined? TAGS
      TAGS = "a|img|em|strong|div|span|table|td|th|ul|ol|li|dl|dt|dd"
      TAGS_PATTERN = Regexp.new('<(?:'+TAGS+')[^>]*?>', Regexp::MULTILINE)
    end
    def self.pattern() TAGS_PATTERN  end
  end

end
