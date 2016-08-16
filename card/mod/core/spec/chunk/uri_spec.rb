# -*- encoding : utf-8 -*-

describe Card::Content::Chunk::URI, "URI chunk tests" do
  it "should test_non_matches" do
    no_match_uri "There is no URI here"
    no_match_uri "One gemstone is the garnet:reddish in colour, like ruby"
  end

  it "works with simple uri" do
    # Simplest case
    match_http_uri "http://www.example.com",
                   host: "www.example.com", path: ""
  end
  it "works with trailing slash" do
    match_http_uri "http://www.example.com/",
                   host: "www.example.com", path: "/"
  end
  it "works with trailing slash inside html tags" do
    match_http_uri "<p>http://www.example.com/</p>",
                   host: "www.example.com", path: "/",
                   link_text: "http://www.example.com/"
  end
  it "works with trailing period (no longer suppressed .. spec?)" do
    match_http_uri "http://www.example.com/. ",
                   host: "www.example.com", path: "/",
                   link_text: "http://www.example.com/"
  end
  it "works with trailing period inside html tags (dot change?)" do
    match_http_uri "<p>http://www.example.com/.</p>",
                   host: "www.example.com", path: "/",
                   link_text: "http://www.example.com/"
  end
  it "works with trailing &nbsp;" do
    match_http_uri "http://www.example.com/&nbsp;",
                   host: "www.example.com", path: "/",
                   link_text: "http://www.example.com/"
  end
  it "works without http://" do
    match_http_uri "www.example.com",
                   host: "www.example.com",
                   text: "www.example.com",
                   link_text: "http://www.example.com"
    match_http_uri "example.com",
                   host: "example.com",
                   text: "example.com",
                   link_text: "http://example.com"
  end
  it 'should match "unusual" base domain (was a bug in an early version)' do
    match_http_uri "http://example.com.au/",
                   host: "example.com.au"
  end
  it 'works with "unusual" base domain without http://' do
    match_http_uri "example.com.au",
                   host: "example.com.au",
                   text: "example.com.au",
                   link_text: "http://example.com.au"
  end
  it 'works with another "unusual" base domain' do
    match_http_uri "http://www.example.co.uk/",
                   host: "www.example.co.uk"
    match_http_uri "example.co.uk",
                   host: "example.co.uk",
                   text: "example.co.uk",
                   link_text: "http://example.co.uk"
  end
  it "works with some path at the end" do
    match_http_uri "http://moinmoin.wikiwikiweb.de/HelpOnNavigation",
                   host: "moinmoin.wikiwikiweb.de",
                   path: "/HelpOnNavigation"
  end
  it "works with some path at the end, and without http:// prefix "\
     "(@link_text has prefix added)" do
    match_http_uri "moinmoin.wikiwikiweb.de/HelpOnNavigation",
                   host: "moinmoin.wikiwikiweb.de",
                   path: "/HelpOnNavigation",
                   text: "moinmoin.wikiwikiweb.de/HelpOnNavigation",
                   link_text: "http://moinmoin.wikiwikiweb.de/HelpOnNavigation"
  end
  it "works with a port number" do
    match_http_uri "http://www.example.com:80",
                   host: "www.example.com", port: 80,
                   path: ""
  end
  it "works with a port number and a path" do
    match_http_uri "http://www.example.com.tw:80/HelpOnNavigation",
                   host: "www.example.com.tw", port: 80,
                   path: "/HelpOnNavigation"
  end
  it "works with a query" do
    match_http_uri "http://www.example.com.tw:80/HelpOnNavigation?arg=val",
                   host: "www.example.com.tw", port: 80,
                   path: "/HelpOnNavigation", query: "arg=val"
  end
  it "works on Query with two arguments" do
    match_http_uri "http://www.example.com.tw:80/HelpOnNavigation"\
                   "?arg=val&arg2=val2",
                   host: "www.example.com.tw", port: 80,
                   path: "/HelpOnNavigation", query: "arg=val&arg2=val2"
  end
  it "works with IRC" do
    match_uri "irc://irc.freenode.net#recentchangescamp",
              scheme: "irc", host: "irc.freenode.net",
              fragment: "recentchangescamp",
              link_text: "irc://irc.freenode.net#recentchangescamp"
  end

  it "should see HTTPS" do
    match_uri "https://www.example.com",
              scheme: "https", host: "www.example.com", port: 443,
              path: "", query: nil
  end
  it "should see FTP" do
    match_uri "ftp://www.example.com",
              scheme: "ftp", host: "www.example.com", port: 21,
              path: "", query: nil
  end
  it "should handle mailto:" do
    match_uri "mailto:jdoe123@example.com",
              scheme: "mailto", host: nil, port: nil,
              path: nil, query: nil,
              to: "jdoe123@example.com"
  end

  it "should run more basic cases" do
    # from *css (with () around the URI)
    # so, now this doesn't even match because I fixed the suspiciou* stuff
    no_match_uri(
      "background: url('http://dl.dropbox.com/u/4657397/wikirate/" \
      "wikirate_files/wr-bg-menu-line.gif') repeat-x;"
    )

    # Soap opera (the most complex case imaginable... well, not really, there
    # should be more evil)
    match_http_uri(
      "http://www.example.com.tw:80/~jdoe123/Help%20Me%20?arg=val&arg2=val2",
      host: "www.example.com.tw", port: 80,
      path: "/~jdoe123/Help%20Me%20", query: "arg=val&arg2=val2"
    )

    # from 0.9 bug reports
    match_uri "http://www2.pos.to/~tosh/ruby/rdtool/en/doc/rd-draft.html",
              scheme: "http", host: "www2.pos.to",
              path: "/~tosh/ruby/rdtool/en/doc/rd-draft.html"

    match_uri "http://support.microsoft.com/default.aspx?scid=kb;en-us;234562",
              scheme: "http", host: "support.microsoft.com",
              path: "/default.aspx", query: "scid=kb;en-us;234562"
  end

  it "should test_email_uri" do
    match_uri "mail@example.com",
              to: "mail@example.com", host: nil,
              text: "mail@example.com",
              link_text: "mailto:mail@example.com"
  end

  it "should test_non_email" do
    # The @ is part of the normal text, but 'example.com' is marked up.
    match_uri "Not an email: @example.com", uri: "http://example.com"
  end

  it "should test_textile_image" do
    no_match_uri "This !http://hobix.com/sample.jpg! is a Textile image link."
  end

  it "should test_textile_link" do
    no_match_uri(
      'This "hobix (hobix)":http://hobix.com/sample.jpg is a Textile link.'
    )
    # just to be sure ...
    match_uri "This http://hobix.com/sample.jpg should match",
              link_text: "http://hobix.com/sample.jpg"
  end

  it "should test_inline_html" do
    no_match_uri "<img src='http://hobix.com/sample.jpg'/>"
    no_match_uri '<IMG SRC="http://hobix.com/sample.jpg">'
  end

  it "should test_non_uri" do
    # "so" is a valid country code; "libproxy.so" is a valid url
    match_uri "libproxy.so", host: "libproxy.so",
                             text: "libproxy.so",
                             link_text: "http://libproxy.so"

    no_match_uri "httpd.conf"
    # THIS ONE'S BUSTED.. Ethan fix??
    # no_match_uri 'ld.so.conf'
    no_match_uri "index.jpeg"
    no_match_uri "index.jpg"
    no_match_uri "file.txt"
    no_match_uri "file.doc"
    no_match_uri "file.pdf"
    no_match_uri "file.png"
    no_match_uri "file.ps"
  end

  it "should test_uri_in_text" do
    match_uri "Go to: http://www.example.com/",
              host: "www.example.com", path: "/"
    match_uri "http://www.example.com/ is a link.", host: "www.example.com"
    match_uri "Email david@loudthinking.com",
              scheme: "mailto", to: "david@loudthinking.com", host: nil
    # check that trailing punctuation is not included in the hostname
    match_uri "Hey dude, http://fake.link.com.",
              scheme: "http", host: "fake.link.com"
    # this is a textile link, no match please.
    no_match_uri '"link":http://fake.link.com.'
  end

  it "should test_uri_in_parentheses" do
    match_uri "URI (http://brackets.com.de) in brackets",
              host: "brackets.com.de"
    match_uri "because (as shown at research.net) the results",
              host: "research.net"
    match_uri "A wiki (http://wiki.org/wiki.cgi?WhatIsWiki) card",
              scheme: "http", host: "wiki.org", path: "/wiki.cgi",
              query: "WhatIsWiki"
  end

  it "should test_uri_list_item" do
    match_chunk(
      Card::Content::Chunk::URI,
      "* http://www.btinternet.com/~mail2minh/SonyEricssonP80xPlatform.sis",
      path: "/~mail2minh/SonyEricssonP80xPlatform.sis"
    )
  end

  it "should test_interesting_uri_with__comma" do
    # Counter-intuitively, this URL matches, but the query part includes the
    # trailing comma.
    # It has no way to know that the query does not include the comma.
    # The trailing , addition breaks this test, but is this test actually valid?
    # It seems better to exclude the comma from the uri, YMMV
    match_uri(
      "This text contains a URL http://someplace.org:8080/~person/stuff.cgi" \
      "?arg=val, doesn't it?",
      scheme: "http", host: "someplace.org", port: 8080,
      path: "/~person/stuff.cgi", query: "arg=val"
    )
  end

  describe Card::Content::Chunk::URI, "URI chunk tests" do
    it "should test_local_urls" do
      # normal
      match_http_uri "http://perforce:8001/toto.html",
                     host: "perforce", port: 8001
      # in parentheses
      match_uri "URI (http://localhost:2500) in brackets",
                host: "localhost", port: 2500
      match_uri "because (as shown at http://perforce:8001) the results",
                host: "perforce", port: 8001
      match_uri "A wiki (http://localhost:2500/wiki.cgi?WhatIsWiki) card",
                scheme: "http", host: "localhost", path: "/wiki.cgi",
                port: 2500, query: "WhatIsWiki"
    end
  end

  private

  DUMMY_CARD = Card.new(name: "dummy")

  # Asserts a number of tests for the given type and text.
  def no_match type, test_text
    expect(get_chunk(type, test_text)).to be_nil
  end

  def match_chunk type, test_text, expected
    chunk = get_chunk(type, test_text)
    expect(chunk).not_to be_nil

    expected.each_pair do |method_sym, value|
      # assert_respond_to(chunk, method_sym)
      cvalue = chunk.method(method_sym).call
      cvalue = cvalue.to_s if method_sym == :uri
      assert_equal(value, cvalue, "Checking value of '#{method_sym}'")
    end
  end

  def match_uri uri, opts
    match_chunk Card::Content::Chunk::URI, uri, opts
  end

  def no_match_uri text
    no_match Card::Content::Chunk::URI, text
  end

  def match_http_uri uri, opts
    match_uri uri, opts.reverse_merge(link_text: uri, scheme: "http")
  end

  def get_chunk type, test_text
    cont = Card::Content.new(test_text, DUMMY_CARD)
    cont = [cont] unless cont.respond_to?(:each)
    cont.find { |ck| ck.is_a? type }
  end
end
