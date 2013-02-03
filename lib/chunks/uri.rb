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

  SCHEMES = %w{http https ftp ssh git sftp file}
  STANDARD_URI_REGEXP = URI.regexp( SCHEMES )
  STANDARD_URI_GROUPS = URI.split('http://local/').length

  def URIChunk.pattern; STANDARD_URI_REGEXP end
  def URIChunk.groups ; STANDARD_URI_GROUPS end

  # FIXME: Delegate to URI class methods
  #attr_reader :user, :host, :port, :path, :query, :fragment, :link_text
  attr_reader :uri

  def initialize match, card_params, params
    super
    @link_text = match

    #warn "parsing: #{match}"
    @uri = URI.parse( match )
    #@process_chunk = self.renderer ? "#{self.renderer.build_link(self.uri,@link_text)}#{@trailing_punctuation}" : @text
  end
end

# uri with mandatory scheme but less restrictive hostname, like
# http://localhost:2500/blah.html
# FIXME: do we need this?  URIChunk should match all of them now, and tests are updated to use that only
#class LocalURIChunk < URIChunk

#end
