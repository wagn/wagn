require 'uri'
require_dependency 'chunks/chunk'

# This wiki chunk matches arbitrary URIs, using patterns from the Ruby URI modules.
# It parses out a variety of fields that could be used by renderers to format
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
# I'm using a part of the [ISO 3166-1 Standard][iso3166] for country name suffixes.
# The generic names are from www.bnoack.com/data/countrycode2.html)
#   [iso3166]: http://geotags.com/iso3166/
class URIChunk < Chunks::Abstract

  SCHEMES = %w{irc http https ftp ssh git sftp file ldap ldaps mailto}

  #REJECTED_PREFIX_RE = '(?!":|!|"|\'|\\]\\()'  # any of ":, !, ", ', ](
  REJECTED_PREFIX_RE = ''  # disabled

  attr_reader :uri, :link_text
  delegate :scheme, :user, :host, :port, :path, :query, :fragment, :to => :uri

  GENERIC = 'aero|biz|com|coop|edu|gov|info|int|mil|museum|name|net|org'

  COUNTRY = 'ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|az|ba|bb|bd|be|' +
    'bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cf|cd|cg|ch|ci|ck|cl|' +
    'cm|cn|co|cr|cs|cu|cv|cx|cy|cz|de|dj|dk|dm|do|dz|ec|ee|eg|eh|er|es|et|fi|' +
    'fj|fk|fm|fo|fr|fx|ga|gb|gd|ge|gf|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|' +
    'hk|hm|hn|hr|ht|hu|id|ie|il|in|io|iq|ir|is|it|jm|jo|jp|ke|kg|kh|ki|km|kn|' +
    'kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|mg|mh|mk|ml|mm|' +
    'mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nt|' +
    'nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|pt|pw|py|qa|re|ro|ru|rw|sa|sb|sc|' +
    'sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|' +
    'tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|um|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|' +
    'ws|ye|yt|yu|za|zm|zr|zw|' +
    'eu' # made this separate, since it's not technically a country -efm
    # These are needed otherwise HOST will match almost anything

  #TLDS = "(?:#{GENERIC}|#{COUNTRY})"
  TLDS = "(?:#{GENERIC})"

  GENERIC_TLDS = 'aero|biz|com|coop|edu|gov|info|int|mil|museum|name|net|org'
  URI_CONFIG = {
    :class     => URIChunk,
    :prefix_re => "#{REJECTED_PREFIX_RE}(?:#{SCHEMES * '|'})\\:",
    :regexp    => /^#{URI.regexp( SCHEMES )}/,
    :prepend_str => '',
    :idx_char  => ':'
  }

  def URIChunk.config; URI_CONFIG end

  def initialize match, card_params, params
    super
    last_char = match[-1]
    match.gsub!(/(?:&nbsp;)+/, '')

    @trailing_punctuation = if %w{ . ) ! ? : }.member?(last_char)
      ch = match.chop!
      last_char
    end
    match.sub!(/\.$/, '')

    @link_text = match

    #warn "parsing[#{self.class}]#{@trailing_punctuation}>#{match}"
    @uri = URI.parse( match )
    @process_chunk = self.renderer ? "#{self.renderer.build_link(@link_text, @link_text)}#{@trailing_punctuation}" : @text
    #warn "init URI[#{@process_chunk}]#{link_text}, #{uri.inspect}:: #{uri.scheme}, #{uri.host}, #{uri.port}, #{uri.path}, #{uri.query}"
    self
  end
end

class EmailURIChunk < URIChunk

  PREPEND_STR = 'mailto:'
  EMAIL = "[a-zA-Z\d](?:[-a-zA-Z\d]*[a-zA-Z\d])?\\@"
  EMAIL_URI_CONFIG = {
    :class     => EmailURIChunk,
    :prefix_re => "#{REJECTED_PREFIX_RE}#{EMAIL}",
    :regexp    => /^#{URI.regexp( SCHEMES )}/,
    :prepend_str => PREPEND_STR,
    :idx_char  => '@'
  }

  def EmailURIChunk.config; EMAIL_URI_CONFIG end

  def initialize match, card_params, params
    super
    @process_chunk = self.renderer ? "#{self.renderer.build_link(@link_text, @link_text.sub(/^http:\/\//,''))}#{@trailing_punctuation}" : @text
  end
end

class HostURIChunk < URIChunk

  PREPEND_STR = 'http://'
  HOST = "(?:[a-zA-Z\d](?:[-a-zA-Z\d]*[a-zA-Z\d])?\\.)+#{TLDS}"
  HOST_URI_CONFIG = {
    :class     => HostURIChunk,
    :prefix_re => "#{REJECTED_PREFIX_RE}#{HOST}",
    :regexp    => /^#{URI.regexp( SCHEMES )}/,
    :prepend_str => PREPEND_STR
  }

  def HostURIChunk.config; HOST_URI_CONFIG end

  def initialize match, card_params, params
    super
    @process_chunk = self.renderer ? "#{self.renderer.build_link(@link_text, @link_text.sub(/^http:\/\//,''))}#{@trailing_punctuation}" : @text
  end
end
