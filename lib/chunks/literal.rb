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
      ESCAPE_PATTERN = /\\((\[|\{){2}[^\]\}]*[\]\}]{2})/
      ESCAPE_GROUPS = 2
    end
    def self.pattern() ESCAPE_PATTERN end
    def self.groups() ESCAPE_GROUPS end

    def initialize match, card_params, params
      super
      first = params[1]
      @process_chunk = "#{params[0].sub(first, "<span>#{first}</span>")}"
    end
  end

  # A literal chunk that protects 'code' and 'pre' tags from wiki rendering.
  #class Pre < AbstractLiteral
  #  unless defined? PRE_PATTERN
  #    PRE_PATTERN = /\/\*(.*?)\*\//
  #  end
  #  def self.pattern() PRE_PATTERN end
  #
  #  def initialize(match_data, content)
  #    super
  #    @process_chunk = "<code>#{match_data[1]}</code>"
  #  end


#    unless defined? PRE_BLOCKS
#      PRE_BLOCKS = "a|pre|code"
#      PRE_PATTERN = Regexp.new('<('+PRE_BLOCKS+')\b[^>]*?>.*?</\1>', Regexp::MULTILINE)
#    end
#  end

=begin
  # A literal chunk that protects HTML tags from wiki rendering.
  class Tags < AbstractLiteral
    unless defined? TAGS
      TAGS = "a|img|em|strong|div|span|table|td|th|ul|ol|li|dl|dt|dd"
      TAGS_PATTERN = Regexp.new('<('+TAGS+')[^>]*?>', Regexp::MULTILINE)
      TAGS_GROUP = 1
    end
    def self.pattern() TAGS_PATTERN  end
  end
=end

end
