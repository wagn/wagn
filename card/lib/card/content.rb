# -*- encoding : utf-8 -*-

# TODO: move Card::Chunk to Card::Content::Chunk...
require_dependency 'card/chunk'

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

      unless Array === content
        content = parse_content content
      end
      super content
    end

    def card
      format.card
    end

    def chunk_list
      @opts[:chunk_list] || @format.chunk_list
    end

    def to_s
      case __getobj__
      when Array    then map(&:to_s) * ''
      when String   then __getobj__
      when NilClass then '' # raise "Nil Card::Content"
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
        Rails.logger.warn 'error self is unrecognized type' \
                          " #{self.class} #{__getobj__.class}"
      end
    end

    def find_chunks chunk_type
      each_chunk.select { |chunk| chunk.is_a?(chunk_type) }
    end

    def process_each_chunk &block
      each_chunk { |chunk| chunk.process_chunk &block }
      self
    end

    def parse_content content
      @chunks = []

      if content.is_a? String
        position = last_position = 0
        prefix_regexp = Chunk.get_prefix_regexp chunk_list
        interval_string = ''

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

          chunk_class = Chunk.find_class_by_prefix prefix
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
              @chunks << interval_string if interval_string.size > 0
              # add the nonchunk string to the chunk list
              @chunks << chunk_class.new(match, self)
              # add the chunk to the chunk list
              interval_string = ''
              # reset interval string for next go-round
              last_position = position
              # note that the end of the chunk was the last place where a
              # chunk was found (so far)
            end
          else
            position += 1
            # no match.  look at the next character
          end

          if !match || !context_ok
            interval_string += content[chunk_start..position - 1]
            # moving beyond the alleged chunk.
            # append failed string to "nonchunk" string
          end
        end
      end

      if chunks.any?
        if last_position < content.size
          remainder = content[last_position..-1]
          # handle any leftover nonchunk string at the end of content
          @chunks << remainder
        end
        chunks
      else
        content
      end
    end

    ALLOWED_TAGS = {}
    %w{
      br i b pre cite caption strong em ins sup sub del ol hr ul li p
      div h1 h2 h3 h4 h5 h6 span table tr td th tbody thead tfoot
    }.each { |tag| ALLOWED_TAGS[tag] = [] }

    # allowed attributes
    ALLOWED_TAGS.merge!(
      'a' => ['href', 'title', 'target'],
      'img' => ['src', 'alt', 'title'],
      'code' => ['lang'],
      'blockquote' => ['cite']
    )

    if Card.config.allow_inline_styles
      ALLOWED_TAGS['table'] += %w[ cellpadding align border cellspacing ]
    end

    ALLOWED_TAGS.each_key do |k|
      ALLOWED_TAGS[k] << 'class'
      ALLOWED_TAGS[k] << 'style' if Card.config.allow_inline_styles
      ALLOWED_TAGS[k]
    end
    ALLOWED_TAGS

    ATTR_VALUE_RE = [/(?<=^')[^']+(?=')/, /(?<=^")[^"]+(?=")/, /\S+/]

    class << self
      ## Method that cleans the String of HTML tags
      ## and attributes outside of the allowed list.

      # this has been hacked for card to allow classes if
      # the class begins with "w-"
      def clean!(string, tags=ALLOWED_TAGS)
        string.gsub(/<(\/*)(\w+)([^>]*)>/) do
          raw = $~
          tag = raw[2].downcase
          if (attrs = tags[tag])
            html_attribs =
              attrs.inject([tag]) do |pcs, attr|
                q = '"'
                rest_value = nil
                if raw[3] =~ /\b#{attr}\s*=\s*(?=(.))/i
                  rest_value = $'
                  (idx = %w{' "}.index($1)) && (q = $1)
                  re = ATTR_VALUE_RE[idx || 2]
                  if (match = rest_value.match(re))
                    rest_value = match[0]
                    if attr == 'class'
                      rest_value =
                        rest_value.split(/\s+/).select do |s|
                          s =~ /^w-/i
                        end * ' '
                    end
                  end
                end
                pcs << "#{attr}=#{q}#{rest_value}#{q}" unless rest_value.blank?
                pcs
              end * ' '
            "<#{raw[1]}#{html_attribs}>"
          else
            ' '
          end
        end.gsub(/<\!--.*?-->/, '')
      end

      if Card.config.space_last_in_multispace
        def clean_with_space_last! string, tags=ALLOWED_TAGS
          cwo = clean_without_space_last!(string, tags)
          cwo.gsub(/(?:^|\b) ((?:&nbsp;)+)/, '\1 ')
        end
        alias_method_chain :clean!, :space_last
      end

      def truncatewords_with_closing_tags input, words=25, truncate_string='...'
        if input.nil? then return end
        wordlist = input.to_s.split
        l = words.to_i - 1
        l = 0 if l < 0
        wordstring = wordlist.length > l ? wordlist[0..l].join(' ') : input.to_s
        # nuke partial tags at end of snippet
        wordstring.gsub!(/(<[^\>]+)$/, '')

        tags = []

        # match tags with or without self closing (ie. <foo />)
        wordstring.scan(/\<([^\>\s\/]+)[^\>]*?\>/).each do |t|
          tags.unshift(t[0])
        end
        # match tags with self closing and mark them as closed
        wordstring.scan(/\<([^\>\s\/]+)[^\>]*?\/\>/).each do |t|
          if !(x = tags.index(t[0])).nil? then tags.slice!(x) end
        end
        # match close tags
        wordstring.scan(/\<\/([^\>\s\/]+)[^\>]*?\>/).each do |t|
          if !(x = tags.rindex(t[0])).nil? then tags.slice!(x) end
        end

        tags.each { |t| wordstring += "</#{t}>" }

        if wordlist.length > l
          wordstring += '<span class="closed-content-ellipses">...</span>'
        end

        # wordstring += '...' if wordlist.length > l
        wordstring.gsub! /<[\/]?br[\s\/]*>/, ' '
        # Also a hack -- get rid of <br>'s -- they make line view ugly.
        wordstring.gsub! /<[\/]?p[^>]*>/, ' '
        ## Also a hack -- get rid of <br>'s -- they make line view ugly.
        wordstring
      end
    end
  end
end
