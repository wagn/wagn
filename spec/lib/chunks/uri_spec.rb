require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe URIChunk, "URI chunk tests" do
  it "should test_non_matches" do
    no_match(URIChunk, 'There is no URI here')
    no_match(URIChunk,
        'One gemstone is the garnet:reddish in colour, like ruby')
  end

  it "should test_simple_uri" do
    # Simplest case
    match_chunk(URIChunk, 'http://www.example.com',
      :scheme =>'http', :host =>'www.example.com', :path => nil,
      :link_text => 'http://www.example.com'
    )
    # With trailing slash
    match_chunk(URIChunk, 'http://www.example.com/',
      :scheme =>'http', :host =>'www.example.com', :path => '/',
      :link_text => 'http://www.example.com/'
    )
    # With trailing slash inside html tags
    match_chunk(URIChunk, '<p>http://www.example.com/</p>',
      :scheme =>'http', :host =>'www.example.com', :path => '/',
      :link_text => 'http://www.example.com/'
    )
    # With trailing period
    match_chunk(URIChunk, 'http://www.example.com/. ',
      :scheme =>'http', :host =>'www.example.com', :path => '/',
      :link_text => 'http://www.example.com/'
    )
    # With trailing period inside html tags
    match_chunk(URIChunk, '<p>http://www.example.com/.</p>',
      :scheme =>'http', :host =>'www.example.com', :path => '/',
      :link_text => 'http://www.example.com/'
    )
    # With trailing &nbsp;
    match_chunk(URIChunk, 'http://www.example.com/&nbsp;',
      :scheme =>'http', :host =>'www.example.com', :path => '/',
      :link_text => 'http://www.example.com/'
    )
    # Without http://
    match_chunk(URIChunk, 'www.example.com',
      :scheme =>'http', :host =>'www.example.com', :link_text => 'www.example.com'
    )
    # two parts
    match_chunk(URIChunk, 'example.com',
      :scheme =>'http',:host =>'example.com', :link_text => 'example.com'
    )
    # "unusual" base domain (was a bug in an early version)
    match_chunk(URIChunk, 'http://example.com.au/',
      :scheme =>'http', :host =>'example.com.au', :link_text => 'http://example.com.au/'
    )
    # "unusual" base domain without http://
    match_chunk(URIChunk, 'example.com.au',
      :scheme =>'http', :host =>'example.com.au', :link_text => 'example.com.au'
    )
    # Another "unusual" base domain
    match_chunk(URIChunk, 'http://www.example.co.uk/',
      :scheme =>'http', :host =>'www.example.co.uk',
      :link_text => 'http://www.example.co.uk/'
    )
    match_chunk(URIChunk, 'example.co.uk',
      :scheme =>'http', :host =>'example.co.uk', :link_text => 'example.co.uk'
    )
    # With some path at the end
    match_chunk(URIChunk, 'http://moinmoin.wikiwikiweb.de/HelpOnNavigation',
      :scheme => 'http', :host => 'moinmoin.wikiwikiweb.de', :path => '/HelpOnNavigation',
      :link_text => 'http://moinmoin.wikiwikiweb.de/HelpOnNavigation'
    )
    # With some path at the end, and withot http:// prefix
    match_chunk(URIChunk, 'moinmoin.wikiwikiweb.de/HelpOnNavigation',
      :scheme => 'http', :host => 'moinmoin.wikiwikiweb.de', :path => '/HelpOnNavigation',
      :link_text => 'moinmoin.wikiwikiweb.de/HelpOnNavigation'
    )
    # With a port number
    match_chunk(URIChunk, 'http://www.example.com:80',
        :scheme =>'http', :host =>'www.example.com', :port => '80', :path => nil,
        :link_text => 'http://www.example.com:80')
    # With a port number and a path
    match_chunk(URIChunk, 'http://www.example.com.tw:80/HelpOnNavigation',
        :scheme =>'http', :host =>'www.example.com.tw', :port => '80', :path => '/HelpOnNavigation',
        :link_text => 'http://www.example.com.tw:80/HelpOnNavigation')
    # With a query
    match_chunk(URIChunk, 'http://www.example.com.tw:80/HelpOnNavigation?arg=val',
        :scheme =>'http', :host =>'www.example.com.tw', :port => '80', :path => '/HelpOnNavigation',
        :query => 'arg=val',
        :link_text => 'http://www.example.com.tw:80/HelpOnNavigation?arg=val')
    # Query with two arguments
    match_chunk(URIChunk, 'http://www.example.com.tw:80/HelpOnNavigation?arg=val&arg2=val2',
        :scheme =>'http', :host =>'www.example.com.tw', :port => '80', :path => '/HelpOnNavigation',
        :query => 'arg=val&arg2=val2',
        :link_text => 'http://www.example.com.tw:80/HelpOnNavigation?arg=val&arg2=val2')
    # with an anchor
    match_chunk(URIChunk, 'irc://irc.freenode.net#recentchangescamp',
        :scheme =>'irc', :host =>'irc.freenode.net',
        :fragment => '#recentchangescamp',
        :link_text => 'irc://irc.freenode.net#recentchangescamp')

    # HTTPS
    match_chunk(URIChunk, 'https://www.example.com',
        :scheme =>'https', :host =>'www.example.com', :port => nil, :path => nil, :query => nil,
        :link_text => 'https://www.example.com')
    # FTP
    match_chunk(URIChunk, 'ftp://www.example.com',
        :scheme =>'ftp', :host =>'www.example.com', :port => nil, :path => nil, :query => nil,
        :link_text => 'ftp://www.example.com')
    # mailto
    match_chunk(URIChunk, 'mailto:jdoe123@example.com',
        :scheme =>'mailto', :host =>'example.com', :port => nil, :path => nil, :query => nil,
        :user => 'jdoe123', :link_text => 'mailto:jdoe123@example.com')
    # something nonexistant
    match_chunk(URIChunk, 'foobar://www.example.com',
        :scheme =>'foobar', :host =>'www.example.com', :port => nil, :path => nil, :query => nil,
        :link_text => 'foobar://www.example.com')

    # Soap opera (the most complex case imaginable... well, not really, there should be more evil)
    match_chunk(URIChunk, 'http://www.example.com.tw:80/~jdoe123/Help%20Me%20?arg=val&arg2=val2',
        :scheme =>'http', :host =>'www.example.com.tw', :port => '80',
        :path => '/~jdoe123/Help%20Me%20', :query => 'arg=val&arg2=val2',
        :link_text => 'http://www.example.com.tw:80/~jdoe123/Help%20Me%20?arg=val&arg2=val2')

    # from 0.9 bug reports
    match_chunk(URIChunk, 'http://www2.pos.to/~tosh/ruby/rdtool/en/doc/rd-draft.html',
        :scheme =>'http', :host => 'www2.pos.to',
        :path => '/~tosh/ruby/rdtool/en/doc/rd-draft.html')

    match_chunk(URIChunk, 'http://support.microsoft.com/default.aspx?scid=kb;en-us;234562',
        :scheme =>'http', :host => 'support.microsoft.com', :path => '/default.aspx',
        :query => 'scid=kb;en-us;234562')

  end

  it "should test_email_uri" do
    match_chunk(URIChunk, 'mail@example.com',
      :user => 'mail', :host => 'example.com', :link_text => 'mail@example.com'
    )
  end

  it "should test_non_email" do
    # The @ is part of the normal text, but 'example.com' is marked up.
     match_chunk(URIChunk, 'Not an email: @example.com', :user => nil, :uri => 'http://example.com')
  end

  it "should test_textile_image" do
    aa_match(URIChunk,
             'This !http://hobix.com/sample.jpg! is a Textile image link.')
  end

  it "should test_textile_link" do
    aa_match(URIChunk,
             'This "hobix (hobix)":http://hobix.com/sample.jpg is a Textile link.')
    # just to be sure ...
    match_chunk(URIChunk, 'This http://hobix.com/sample.jpg should match',
          :link_text => 'http://hobix.com/sample.jpg')
  end

  it "should test_inline_html" do
    no_match(URIChunk, '<IMG SRC="http://hobix.com/sample.jpg">')
    no_match(URIChunk, "<img src='http://hobix.com/sample.jpg'/>")
  end

  it "should test_non_uri" do
    # "so" is a valid country code; "libproxy.so" is a valid url
    match_chunk(URIChunk, 'libproxy.so', :link_text => 'libproxy.so')

    no_match URIChunk, 'httpd.conf'
    # THIS ONE'S BUSTED.. Ethan fix??
    #no_match URIChunk, 'ld.so.conf'
    no_match URIChunk, 'index.jpeg'
    no_match URIChunk, 'index.jpg'
    no_match URIChunk, 'file.txt'
    no_match URIChunk, 'file.doc'
    no_match URIChunk, 'file.pdf'
    no_match URIChunk, 'file.png'
    no_match URIChunk, 'file.ps'
  end

  it "should test_uri_in_text" do
    match_chunk(URIChunk, 'Go to: http://www.example.com/', :host => 'www.example.com', :path =>'/')
    match_chunk(URIChunk, 'http://www.example.com/ is a link.', :host => 'www.example.com')
    match_chunk(URIChunk,
        'Email david@loudthinking.com',
        :scheme =>'mailto', :user =>'david', :host =>'loudthinking.com')
    # check that trailing punctuation is not included in the hostname
    match_chunk(URIChunk, 'Hey dude, http://fake.link.com.', :scheme => 'http', :host => 'fake.link.com')
    # this is a textile link, no match please.
    aa_match(URIChunk, '"link":http://fake.link.com.')
   end

  it "should test_uri_in_parentheses" do
    match_chunk(URIChunk, 'URI (http://brackets.com.de) in brackets', :host => 'brackets.com.de')
    match_chunk(URIChunk, 'because (as shown at research.net) the results', :host => 'research.net')
    match_chunk(URIChunk,
      'A wiki (http://wiki.org/wiki.cgi?WhatIsWiki) card',
      :scheme => 'http', :host => 'wiki.org', :path => '/wiki.cgi', :query => 'WhatIsWiki'
    )
  end

  it "should test_uri_list_item" do
    match_chunk(
      URIChunk,
      '* http://www.btinternet.com/~mail2minh/SonyEricssonP80xPlatform.sis',
      :path => '/~mail2minh/SonyEricssonP80xPlatform.sis'
    )
  end

  it "should test_interesting_uri_with__comma" do
    # Counter-intuitively, this URL matches, but the query part includes the trailing comma.
    # It has no way to know that the query does not include the comma.
    match_chunk(
        URIChunk,
        "This text contains a URL http://someplace.org:8080/~person/stuff.cgi?arg=val, doesn't it?",
        :scheme => 'http', :host => 'someplace.org', :port => '8080', :path => '/~person/stuff.cgi',
        :query => 'arg=val,')
  end

 describe URIChunk, "URI chunk tests" do
  it "should test_local_urls" do
    # normal
    match_chunk(URIChunk, 'http://perforce:8001/toto.html',
          :scheme => 'http', :host => 'perforce',
          :port => '8001', :link_text => 'http://perforce:8001/toto.html')

    # in parentheses
    match_chunk(URIChunk, 'URI (http://localhost:2500) in brackets',
          :host => 'localhost', :port => '2500')
    match_chunk(URIChunk, 'because (as shown at http://perforce:8001) the results',
          :host => 'perforce', :port => '8001')
    match_chunk(URIChunk,
      'A wiki (http://localhost:2500/wiki.cgi?WhatIsWiki) card',
          :scheme => 'http', :host => 'localhost', :path => '/wiki.cgi',
          :port => '2500', :query => 'WhatIsWiki')
  end
 end

  private
  # Asserts a number of tests for the given type and text.
  def no_match(type, test_text)
    assert type.respond_to? :pattern
    pattern = type.pattern
    if test_text =~ pattern
      params = $~.to_a; m = params.shift
      chunk = type.new(m, {}, params)
      assert( ! chunk.kind_of?(type), "Shouln't match #{type}, #{chunk.inspect}" )
    else
      assert true # didn't match, so we don't have to creat chunk
    end
  end

  def aa_match(type, test_text)
    assert test_text =~ type.pattern
    params = $~.to_a; m = params.shift
    chunk = type.new(m, {}, params)
    assert chunk.avoid_autolinking?
  end

  def match_chunk(type, test_text, expected)
    assert type.respond_to? :pattern
    pattern = type.pattern
    assert_match(pattern, test_text)
    pattern =~ test_text   # Previous assertion guarantees match
    params = $~.to_a; m = params.shift
    chunk = type.new(m, {}, params)
    assert chunk.kind_of?(type)
    # Test if requested parts are correct.
    expected.each_pair do |method_sym, value|
      assert_respond_to(chunk, method_sym)
      assert_equal(value, chunk.method(method_sym).call, "Checking value of '#{method_sym}'")
    end
  end

end
