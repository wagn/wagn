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

  SCHEMES = %w{http https ftp ssh git sftp file ldap ldaps mailto}
  STANDARD_CONFIG = {
    :class     => URIChunk,
    :prefix_re => "(?:#{SCHEMES * '|'})\\:",
    :regexp    => /^#{URI.regexp( SCHEMES )}/
  }

  def URIChunk.config; STANDARD_CONFIG end

  # FIXME: Delegate to URI class methods
  attr_reader :uri, :link_text
  delegate :scheme, :user, :host, :port, :path, :query, :fragment, :to => :uri

  def initialize match, card_params, params
    super
    @link_text = match

    #warn "parsing: #{match}"
    @uri = URI.parse( match )
    #warn "init URI:#{link_text}, #{uri.inspect}:: #{uri.scheme}, #{uri.host}, #{uri.port}, #{uri.path}, #{uri.query}"
    #@process_chunk = self.renderer ? "#{self.renderer.build_link(self.uri,@link_text)}#{@trailing_punctuation}" : @text
    self
  end
end

# uri with mandatory scheme but less restrictive hostname, like
# http://localhost:2500/blah.html
# FIXME: do we need this?  URIChunk should match all of them now, and tests are updated to use that only
#class LocalURIChunk < URIChunk

#end
