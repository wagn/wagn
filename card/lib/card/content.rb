# -*- encoding : utf-8 -*-

require_dependency "card/content/chunk"
require_dependency "card/content/parser"

class Card
  class Content < SimpleDelegator
    attr_reader :revision, :format, :chunks, :opts

    def initialize content, format_or_card, opts={}
      @format =
        if format_or_card.is_a?(Card)
          Format.new format_or_card, format: nil
        else
          format_or_card
        end
      @opts = opts || {}

      @chunks = Parser.new(chunk_list).parse(content, self)
      super(@chunks.any? ? @chunks : content)
    end

    def card
      format.card
    end

    def chunk_list
      @opts[:chunk_list] || @format.chunk_list
    end

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

    def each_chunk
      return enum_for(:each_chunk) unless block_given?
      case __getobj__
      when Hash  then each_value { |v| yield v if v.is_a?(Chunk::Abstract) }
      when Array then each       { |e| yield e if e.is_a?(Chunk::Abstract) }
      when String # noop. strings are parsed in self, so no chunks in a String
      else
        Rails.logger.warn "error self is unrecognized type" \
                          " #{self.class} #{__getobj__.class}"
      end
    end

    def find_chunks chunk_type
      each_chunk.select { |chunk| chunk.is_a?(chunk_type) }
    end

    def process_each_chunk &block
      each_chunk { |chunk| chunk.process_chunk(&block) }
      self
    end

    ALLOWED_TAGS = {}
    %w(
      br i b pre cite caption strong em ins sup sub del ol hr ul li p
      div h1 h2 h3 h4 h5 h6 span table tr td th tbody thead tfoot
    ).each { |tag| ALLOWED_TAGS[tag] = [] }

    # allowed attributes
    ALLOWED_TAGS.merge!(
      "a" => %w(href title target),
      "img" => %w(src alt title),
      "code" => ["lang"],
      "blockquote" => ["cite"]
    )

    if Card.config.allow_inline_styles
      ALLOWED_TAGS["table"] += %w(cellpadding align border cellspacing)
    end

    ALLOWED_TAGS.each_key do |k|
      ALLOWED_TAGS[k] << "class"
      ALLOWED_TAGS[k] << "style" if Card.config.allow_inline_styles
      ALLOWED_TAGS[k]
    end
    ALLOWED_TAGS.freeze

    ATTR_VALUE_RE = [/(?<=^')[^']+(?=')/, /(?<=^")[^"]+(?=")/, /\S+/].freeze

    class << self
      ## Method that cleans the String of HTML tags
      ## and attributes outside of the allowed list.

      # this has been hacked for card to allow classes if
      # the class begins with "w-"
      def clean! string, tags=ALLOWED_TAGS
        string.gsub(%r{<(/*)(\w+)([^>]*)>}) do
          raw = $LAST_MATCH_INFO
          tag = raw[2].downcase
          if (attrs = tags[tag])
            html_attribs =
              attrs.each_with_object([tag]) do |attr, pcs|
                q, rest_value = process_attribute attr, raw[3]
                pcs << "#{attr}=#{q}#{rest_value}#{q}" unless rest_value.blank?
              end * " "
            "<#{raw[1]}#{html_attribs}>"
          else
            " "
          end
        end.gsub(/<\!--.*?-->/, "")
      end

      def process_attribute attr, all_attributes
        return ['"', nil] unless all_attributes =~ /\b#{attr}\s*=\s*(?=(.))/i
        q = '"'
        rest_value = $'
        (idx = %w(' ").index(Regexp.last_match(1))) &&
          (q = Regexp.last_match(1))
        re = ATTR_VALUE_RE[idx || 2]
        if (match = rest_value.match(re))
          rest_value = match[0]
          if attr == "class"
            rest_value =
              rest_value.split(/\s+/).select { |s| s =~ /^w-/i }.join(" ")
          end
        end
        [q, rest_value]
      end

      if Card.config.space_last_in_multispace
        def clean_with_space_last! string, tags=ALLOWED_TAGS
          cwo = clean_without_space_last!(string, tags)
          cwo.gsub(/(?:^|\b) ((?:&nbsp;)+)/, '\1 ')
        end
        alias_method_chain :clean!, :space_last
      end

      def truncatewords_with_closing_tags input, words=25,
                                          _truncate_string="..."
        return if input.nil?
        wordlist = input.to_s.split
        l = words.to_i - 1
        l = 0 if l < 0
        wordstring = wordlist.length > l ? wordlist[0..l].join(" ") : input.to_s
        # nuke partial tags at end of snippet
        wordstring.gsub!(/(<[^\>]+)$/, "")

        tags = find_tags wordstring
        tags.each { |t| wordstring += "</#{t}>" }

        if wordlist.length > l
          wordstring += '<span class="closed-content-ellipses">...</span>'
        end

        # wordstring += '...' if wordlist.length > l
        wordstring.gsub! %r{<[/]?br[\s/]*>}, " "
        # Also a hack -- get rid of <br>'s -- they make line view ugly.
        wordstring.gsub! %r{<[/]?p[^>]*>}, " "
        ## Also a hack -- get rid of <br>'s -- they make line view ugly.
        wordstring
      end

      def find_tags wordstring
        tags = []

        # match tags with or without self closing (ie. <foo />)
        wordstring.scan(%r{\<([^\>\s/]+)[^\>]*?\>}).each do |t|
          tags.unshift(t[0])
        end
        # match tags with self closing and mark them as closed
        wordstring.scan(%r{\<([^\>\s/]+)[^\>]*?/\>}).each do |t|
          next unless (x = tags.index(t[0]))
          tags.slice!(x)
        end
        # match close tags
        wordstring.scan(%r{\</([^\>\s/]+)[^\>]*?\>}).each do |t|
          next unless (x = tags.rindex(t[0]))
          tags.slice!(x)
        end
        tags
      end
    end
  end
end
