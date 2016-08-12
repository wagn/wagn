# -*- encoding : utf-8 -*-
require "uri"

# This wiki chunk matches arbitrary URIs, using patterns from the Ruby URI
# modules.
# It parses out a variety of fields that could be used by formats to format
# the links in various ways (shortening domain names, hiding email addresses)
# It matches email addresses and host.com.au domains without schemes (http://)
# but adds these on as required.
#
# The heuristic used to match a URI is designed to err on the side of caution.
# That is, it is more likely to not autolink a URI than it is to accidently
# autolink something that is not a URI. The reason behind this is it is easier
# to force a URI link by prefixing 'http://' to it than it is to escape and
# incorrectly marked up non-URI.
#
# I'm using a part of the [ISO 3166-1 Standard][iso3166] for country name
# suffixes.
# The generic names are from www.bnoack.com/data/countrycode2.html)
#   [iso3166]: http://geotags.com/iso3166/
module Card::Content::Chunk
  class URI < Abstract
    SCHEMES = %w(irc http https ftp ssh git sftp file ldap ldaps mailto).freeze

    REJECTED_PREFIX_RE = %w{! ": " ' ](}.map { |s| Regexp.escape s } * "|"

    attr_reader :uri, :link_text
    delegate :to, :scheme, :host, :port, :path, :query, :fragment, to: :uri

    Card::Content::Chunk.register_class(
      self, prefix_re: "(?:(?!#{REJECTED_PREFIX_RE})(?:#{SCHEMES * '|'})\\:)",
            full_re: /^#{::URI.regexp(SCHEMES)}/,
            idx_char: ":"
    )

    class << self
      def full_match content, prefix
        prepend_str = if prefix[-1, 1] != ":" && config[:prepend_str]
                        config[:prepend_str]
                      else
                        ""
                      end
        content = prepend_str + content
        match = super content, prefix
        [match, prepend_str.length]
      end

      def context_ok? content, chunk_start
        preceding_string = content[chunk_start - 2..chunk_start - 1]
        !(preceding_string =~ /(?:#{REJECTED_PREFIX_RE})$/)
      end
    end

    def interpret match, _content
      chunk = match[0]
      last_char = chunk[-1, 1]
      chunk.gsub!(/(?:&nbsp;)+/, "")

      @trailing_punctuation =
        if %w{, . ) ! ? :}.member?(last_char)
          @text.chop!
          chunk.chop!
          last_char
        end
      chunk.sub!(/\.$/, "")

      @link_text = chunk
      @uri = ::URI.parse(chunk)
      @process_chunk = process_uri_chunk
    rescue ::URI::Error => e
      # warn "rescue parse #{chunk_class}:
      # '#{m}' #{e.inspect} #{e.backtrace*"\n"}"
      Rails.logger.warn "rescue parse #{self.class}: #{e.inspect}"
    end

    private

    def process_text
      @link_text
    end

    def process_uri_chunk
      link_opts = { text: process_text }
      "#{format.web_link(@link_text, link_opts)}#{@trailing_punctuation}"
    end
  end

  # FIXME: DRY, merge these two into one class
  class EmailURI < URI
    PREPEND_STR = "mailto:".freeze
    EMAIL = '[a-zA-Zd](?:[-a-zA-Zd]*[a-zA-Zd])?\\@'.freeze

    Card::Content::Chunk.register_class(
      self, prefix_re: "(?:(?!#{REJECTED_PREFIX_RE})#{EMAIL})\\b",
            full_re: /^#{::URI.regexp(SCHEMES)}/,
            prepend_str: PREPEND_STR,
            idx_char: "@"
    )

    # removes the prepended string from the unchanged match text
    def process_text
      @text = @text.sub(/^mailto:/, "")
    end
  end

  class HostURI < URI
    GENERIC = "aero|biz|com|coop|edu|gov|info|int|mil|" \
              "museum|name|net|org".freeze

    COUNTRY = "ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|az|ba|bb|bd|be|" \
              "bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cf|cd|cg|" \
              "ch|ci|ck|cl|cm|cn|co|cr|cs|cu|cv|cx|cy|cz|de|dj|dk|dm|do|dz|" \
              "ec|ee|eg|eh|er|es|et|fi|fj|fk|fm|fo|fr|fx|ga|gb|gd|ge|gf|gh|" \
              "gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|" \
              "il|in|io|iq|ir|is|it|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|" \
              "kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|mg|mh|mk|ml|mm|" \
              "mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|" \
              "no|np|nr|nt|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|pt|pw|py|" \
              "qa|re|ro|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|" \
              "st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tm|tn|to|tp|tr|tt|tv|tw|" \
              "tz|ua|ug|uk|um|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|" \
              "za|zm|zr|zw|" \
              "eu".freeze # made this separate, since it's not technically
    # a country -efm
    # These are needed otherwise HOST will match almost anything

    TLDS = "(?:#{GENERIC}|#{COUNTRY})".freeze
    # TLDS = "(?:#{GENERIC})"

    PREPEND_STR = "http://".freeze
    HOST = "(?:[a-zA-Z\d](?:[-a-zA-Z\d]*[a-zA-Z\d])?\\.)+#{TLDS}".freeze

    Card::Content::Chunk.register_class(
      self, prefix_re: "(?:(?!#{REJECTED_PREFIX_RE})#{HOST})\\b",
            full_re: /^#{::URI.regexp(SCHEMES)}/,
            prepend_str: PREPEND_STR
    )

    # removes the prepended string from the unchanged match text
    def process_text
      @text = @text.sub(%r{^http://}, "")
    end
  end
end
