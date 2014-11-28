# -*- encoding : utf-8 -*-

describe Card::Chunk::URI, "URI chunk tests" do
  it "should test_non_matches" do
    no_match(Card::Chunk::URI, 'There is no URI here')
    no_match(Card::Chunk::URI,
        'One gemstone is the garnet:reddish in colour, like ruby')
  end

  it "should test_simple_uri" do
    # Simplest case
    match_chunk(Card::Chunk::URI, 'http://www.example.com',
      :scheme =>'http', :host =>'www.example.com', :path => '',
      :link_text => 'http://www.example.com'
    )
  end
  it "should work with trailing slash" do
    match_chunk(Card::Chunk::URI, 'http://www.example.com/',
      :scheme =>'http', :host =>'www.example.com', :path => '/',
      :link_text => 'http://www.example.com/'
    )
  end
  it "should work with trailing slash inside html tags" do
    match_chunk(Card::Chunk::URI, '<p>http://www.example.com/</p>',
      :scheme =>'http', :host =>'www.example.com', :path => '/',
      :link_text => 'http://www.example.com/'
    )
  end
  it "should work with trailing period (no longer suppressed .. spec?)" do
    match_chunk(Card::Chunk::URI, 'http://www.example.com/. ',
      :scheme =>'http', :host =>'www.example.com', :path => '/',
      :link_text => 'http://www.example.com/'
    )
  end
  it "should work with trailing period inside html tags (dot change?)" do
    match_chunk(Card::Chunk::URI, '<p>http://www.example.com/.</p>',
      :scheme =>'http', :host =>'www.example.com', :path => '/',
      :link_text => 'http://www.example.com/'
    )
  end
  it "should work with trailing &nbsp;" do
    match_chunk(Card::Chunk::URI, 'http://www.example.com/&nbsp;',
      :scheme =>'http', :host =>'www.example.com', :path => '/',
      :link_text => 'http://www.example.com/'
    )
  end
  it "should work without http://" do
    match_chunk(Card::Chunk::URI, 'www.example.com',
      :scheme =>'http', :host =>'www.example.com', :text => 'www.example.com', :link_text => 'http://www.example.com'
    )
    match_chunk(Card::Chunk::URI, 'example.com',
      :scheme =>'http',:host =>'example.com', :text => 'example.com', :link_text => 'http://example.com'
    )
  end
  it "should match \"unusual\" base domain (was a bug in an early version)" do
    match_chunk(Card::Chunk::URI, 'http://example.com.au/',
      :scheme =>'http', :host =>'example.com.au', :link_text => 'http://example.com.au/'
    )
  end
  it 'should work with "unusual" base domain without http://' do
    match_chunk(Card::Chunk::URI, 'example.com.au',
      :scheme =>'http', :host =>'example.com.au', :text => 'example.com.au', :link_text => 'http://example.com.au'
    )
  end
  it 'should work with another "unusual" base domain' do
    match_chunk(Card::Chunk::URI, 'http://www.example.co.uk/',
      :scheme =>'http', :host =>'www.example.co.uk',
      :link_text => 'http://www.example.co.uk/'
    )
    match_chunk(Card::Chunk::URI, 'example.co.uk',
      :scheme =>'http', :host =>'example.co.uk', :link_text => 'http://example.co.uk', :text => 'example.co.uk'
    )
  end
  it "should work with some path at the end" do
    match_chunk(Card::Chunk::URI, 'http://moinmoin.wikiwikiweb.de/HelpOnNavigation',
      :scheme => 'http', :host => 'moinmoin.wikiwikiweb.de', :path => '/HelpOnNavigation',
      :link_text => 'http://moinmoin.wikiwikiweb.de/HelpOnNavigation'
    )
  end
  it "should work with some path at the end, and withot http:// prefix (@link_text has prefix added)" do
    match_chunk(Card::Chunk::URI, 'moinmoin.wikiwikiweb.de/HelpOnNavigation',
      :scheme => 'http', :host => 'moinmoin.wikiwikiweb.de', :path => '/HelpOnNavigation',
      :text => 'moinmoin.wikiwikiweb.de/HelpOnNavigation',
      :link_text => 'http://moinmoin.wikiwikiweb.de/HelpOnNavigation'
    )
  end
  it "should work with a port number" do
    match_chunk(Card::Chunk::URI, 'http://www.example.com:80',
       :scheme =>'http', :host =>'www.example.com', :port => 80, :path => '',
       :link_text => 'http://www.example.com:80')
  end
  it "should work with a port number and a path" do
    match_chunk(Card::Chunk::URI, 'http://www.example.com.tw:80/HelpOnNavigation',
        :scheme =>'http', :host =>'www.example.com.tw', :port => 80, :path => '/HelpOnNavigation',
        :link_text => 'http://www.example.com.tw:80/HelpOnNavigation')
  end
  it "should work with a query" do
    match_chunk(Card::Chunk::URI, 'http://www.example.com.tw:80/HelpOnNavigation?arg=val',
        :scheme =>'http', :host =>'www.example.com.tw', :port => 80, :path => '/HelpOnNavigation',
        :query => 'arg=val',
        :link_text => 'http://www.example.com.tw:80/HelpOnNavigation?arg=val')
  end
  it "should work on Query with two arguments" do
    match_chunk(Card::Chunk::URI, 'http://www.example.com.tw:80/HelpOnNavigation?arg=val&arg2=val2',
        :scheme =>'http', :host =>'www.example.com.tw', :port => 80, :path => '/HelpOnNavigation',
        :query => 'arg=val&arg2=val2',
        :link_text => 'http://www.example.com.tw:80/HelpOnNavigation?arg=val&arg2=val2')
  end
  it "should work with IRC" do
    match_chunk(Card::Chunk::URI, 'irc://irc.freenode.net#recentchangescamp',
        :scheme =>'irc', :host =>'irc.freenode.net',
        :fragment => 'recentchangescamp',
        :link_text => 'irc://irc.freenode.net#recentchangescamp')
  end

  it "should see HTTPS" do
    match_chunk(Card::Chunk::URI, 'https://www.example.com',
        :scheme =>'https', :host =>'www.example.com', :port => 443, :path => '', :query => nil,
        :link_text => 'https://www.example.com')
  end
  it "should see FTP" do
    match_chunk(Card::Chunk::URI, 'ftp://www.example.com',
        :scheme =>'ftp', :host =>'www.example.com', :port => 21, :path => '', :query => nil,
        :link_text => 'ftp://www.example.com')
  end
  it "should handle mailto:" do
    match_chunk(Card::Chunk::URI, 'mailto:jdoe123@example.com',
        :scheme =>'mailto', :host =>nil, :port => nil, :path => nil, :query => nil,
        :to => 'jdoe123@example.com', :link_text => 'mailto:jdoe123@example.com')
  end
    # something nonexistant (pending spec?  this is no longer recognized, the sheme has to be listed)
    #match_chunk(Card::Chunk::URI, 'foobar://www.example.com',
    #    :scheme =>'foobar', :host =>'www.example.com', :port => '', :path => '', :query => nil,
    #    :link_text => 'foobar://www.example.com')

  it "should run more basic cases" do

    # from *css (with () around the URI)
    # so, now this doesn't even match because I fixed the suspiciou* stuff
    no_match(Card::Chunk::URI, "background: url('http://dl.dropbox.com/u/4657397/wikirate/wikirate_files/wr-bg-menu-line.gif') repeat-x;")

    # Soap opera (the most complex case imaginable... well, not really, there should be more evil)
    match_chunk(Card::Chunk::URI, 'http://www.example.com.tw:80/~jdoe123/Help%20Me%20?arg=val&arg2=val2',
        :scheme =>'http', :host =>'www.example.com.tw', :port => 80,
        :path => '/~jdoe123/Help%20Me%20', :query => 'arg=val&arg2=val2',
        :link_text => 'http://www.example.com.tw:80/~jdoe123/Help%20Me%20?arg=val&arg2=val2')

    # from 0.9 bug reports
    match_chunk(Card::Chunk::URI, 'http://www2.pos.to/~tosh/ruby/rdtool/en/doc/rd-draft.html',
        :scheme =>'http', :host => 'www2.pos.to',
        :path => '/~tosh/ruby/rdtool/en/doc/rd-draft.html')

    match_chunk(Card::Chunk::URI, 'http://support.microsoft.com/default.aspx?scid=kb;en-us;234562',
        :scheme =>'http', :host => 'support.microsoft.com', :path => '/default.aspx',
        :query => 'scid=kb;en-us;234562')

  end

  it "should test_email_uri" do
    match_chunk(Card::Chunk::URI, 'mail@example.com',
      :to => 'mail@example.com', :host => nil, :text => 'mail@example.com', :link_text => 'mailto:mail@example.com'
    )
  end

  it "should test_non_email" do
    # The @ is part of the normal text, but 'example.com' is marked up.
     match_chunk(Card::Chunk::URI, 'Not an email: @example.com', :uri => 'http://example.com')
  end

  it "should test_textile_image" do
    no_match(Card::Chunk::URI,
             'This !http://hobix.com/sample.jpg! is a Textile image link.')
  end

  it "should test_textile_link" do
    no_match(Card::Chunk::URI,
             'This "hobix (hobix)":http://hobix.com/sample.jpg is a Textile link.')
    # just to be sure ...
    match_chunk(Card::Chunk::URI, 'This http://hobix.com/sample.jpg should match',
          :link_text => 'http://hobix.com/sample.jpg')
  end

  it "should test_inline_html" do
    no_match(Card::Chunk::URI, "<img src='http://hobix.com/sample.jpg'/>")
    no_match(Card::Chunk::URI, '<IMG SRC="http://hobix.com/sample.jpg">')
  end

  it "should test_non_uri" do
    # "so" is a valid country code; "libproxy.so" is a valid url
    match_chunk(Card::Chunk::URI, 'libproxy.so', :host => 'libproxy.so', :text => 'libproxy.so', :link_text => 'http://libproxy.so')

    no_match Card::Chunk::URI, 'httpd.conf'
    # THIS ONE'S BUSTED.. Ethan fix??
    #no_match Card::Chunk::URI, 'ld.so.conf'
    no_match Card::Chunk::URI, 'index.jpeg'
    no_match Card::Chunk::URI, 'index.jpg'
    no_match Card::Chunk::URI, 'file.txt'
    no_match Card::Chunk::URI, 'file.doc'
    no_match Card::Chunk::URI, 'file.pdf'
    no_match Card::Chunk::URI, 'file.png'
    no_match Card::Chunk::URI, 'file.ps'
  end

  it "should test_uri_in_text" do
    match_chunk(Card::Chunk::URI, 'Go to: http://www.example.com/', :host => 'www.example.com', :path =>'/')
    match_chunk(Card::Chunk::URI, 'http://www.example.com/ is a link.', :host => 'www.example.com')
    match_chunk(Card::Chunk::URI,
        'Email david@loudthinking.com',
        :scheme =>'mailto', :to =>'david@loudthinking.com', :host => nil)
    # check that trailing punctuation is not included in the hostname
    match_chunk(Card::Chunk::URI, 'Hey dude, http://fake.link.com.', :scheme => 'http', :host => 'fake.link.com')
    # this is a textile link, no match please.
    no_match(Card::Chunk::URI, '"link":http://fake.link.com.')
   end

  it "should test_uri_in_parentheses" do
    match_chunk(Card::Chunk::URI, 'URI (http://brackets.com.de) in brackets', :host => 'brackets.com.de')
    match_chunk(Card::Chunk::URI, 'because (as shown at research.net) the results', :host => 'research.net')
    match_chunk(Card::Chunk::URI,
      'A wiki (http://wiki.org/wiki.cgi?WhatIsWiki) card',
      :scheme => 'http', :host => 'wiki.org', :path => '/wiki.cgi', :query => 'WhatIsWiki'
    )
  end

  it "should test_uri_list_item" do
    match_chunk(
      Card::Chunk::URI,
      '* http://www.btinternet.com/~mail2minh/SonyEricssonP80xPlatform.sis',
      :path => '/~mail2minh/SonyEricssonP80xPlatform.sis'
    )
  end

  it "should test_interesting_uri_with__comma" do
    # Counter-intuitively, this URL matches, but the query part includes the trailing comma.
    # It has no way to know that the query does not include the comma.
    # The trailing , addition breaks this test, but is this test actually valid?
    # It seems better to exclude the comma from the uri, YMMV
    match_chunk(
        Card::Chunk::URI,
        "This text contains a URL http://someplace.org:8080/~person/stuff.cgi?arg=val, doesn't it?",
        :scheme => 'http', :host => 'someplace.org', :port => 8080, :path => '/~person/stuff.cgi',
        :query => 'arg=val')
  end

 describe Card::Chunk::URI, "URI chunk tests" do
  it "should test_local_urls" do
    # normal
    match_chunk(Card::Chunk::URI, 'http://perforce:8001/toto.html',
          :scheme => 'http', :host => 'perforce',
          :port => 8001, :link_text => 'http://perforce:8001/toto.html')

    # in parentheses
    match_chunk(Card::Chunk::URI, 'URI (http://localhost:2500) in brackets',
          :host => 'localhost', :port => 2500)
    match_chunk(Card::Chunk::URI, 'because (as shown at http://perforce:8001) the results',
          :host => 'perforce', :port => 8001)
    match_chunk(Card::Chunk::URI,
      'A wiki (http://localhost:2500/wiki.cgi?WhatIsWiki) card',
          :scheme => 'http', :host => 'localhost', :path => '/wiki.cgi',
          :port => 2500, :query => 'WhatIsWiki')
  end
 end

  private
  DUMMY_CARD = Card.new(:name=>'dummy')

  # Asserts a number of tests for the given type and text.
  def no_match(type, test_text)
    test_cont = Card::Content.new(test_text, DUMMY_CARD)
    expect( ((test_cont.respond_to? :each) ? test_cont : [test_cont]).find{|ck| type===ck } ).to be_nil
  end

  def aa_match(type, test_text)
    test_cont = Card::Content.new(test_text, DUMMY_CARD)
    expect( ((test_cont.respond_to? :each) ? test_cont : [test_cont]).find{|ck| type===ck } ).not_to be_nil
  end

  def match_chunk(type, test_text, expected)
    test_cont = Card::Content.new(test_text, DUMMY_CARD)
    chunk = ((test_cont.respond_to? :each) ? test_cont : [test_cont]).find{ |ck| type===ck }
    #warn "chunk? #{chunk.inspect}"
    expect(chunk).not_to be_nil

    expected.each_pair do |method_sym, value|
      #assert_respond_to(chunk, method_sym)
      cvalue = chunk.method(method_sym).call
      cvalue = cvalue.to_s if method_sym == :uri
      assert_equal(value, cvalue, "Checking value of '#{method_sym}'")
    end
  end

end
