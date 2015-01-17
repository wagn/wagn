# -*- encoding : utf-8 -*-
require 'card/content'

CONTENT = {
  :one => %(Some Literals: \\[{I'm not| a link]}, and \\{{This Card|Is not Included}}, but {{this is}}, and some tail),
  #:two => %(Some Links and includes: [[the card|the text]], and {{This Card|Is Included}}{{this too}}
  #       more formats for links and includes: [the card][the text],
  #       and [[http://external.wagn.org/path|link text]][This Card][Is linked]{{Included|open}}),
  :two => %(Some Links and includes: [[the card|the text]], and {{This Card|Is Included}}{{this too}}
        and [[http://external.wagn.org/path|link text]]{{Included|open}}),
         
  :three =>%(Some URIs and Links: http://a.url.com/
        More urls: wagn.com/a/path/to.html
        http://localhost:2020/path?cgi=foo&bar=baz  [[http://brain.org/Home|extra]]
        [ http://gerry.wagn.com/a/path ]
        { https://brain.org/more?args }),
  :three_b => %(Some URIs and Links: http://a.url.com
        More urls: wagn.com/a/path/to.html
        [ http://gerry.wagn.com/a/path ]
        { https://brain.org/more?args }
        http://localhost:2020/path?cgi=foo&bar=baz  [[http://brain.org/Home|extra]]),
   :four => "No chunks",
   :five => "{{one inclusion|size;large}}",
   :six  => %~
     /* body text */
     body {
       color: #444444;
     }

     /* page - background image and color */
     body#wagn {
       background: #ffffff;
     }

     /* top bar background color; text colors */
     #menu {
       background: #3260a0;
     }
     #menu a {
       color: #EEEEEE;
     }

     /* header text */
     h1, h2 {
       color: #664444;
     }
     h1.page-header, 
     h2.page-header {
       color: #222299; 
     }
   ~
}

CLASSES = {
   :one => [String, :EscapedLiteral, String, :Include, String ],
#   :two => [String, Chunk::Link, String, Chunk::Include, Chunk::Include, String, Chunk::Link, String, Chunk::Link, Chunk::Link, Chunk::Include ],
   :two => [String, :Link, String, :Include, :Include, String, :Link, :Include ],
   :three => [String, :URI, String, :HostURI, String, :URI, String, :Link, String, :URI, String, :URI, String ],
   :three_b => [String, :URI, String, :HostURI, String, :URI, String, :URI, String, :URI, String, :Link ],
   :five => [:Include]
}

CLASSES.each do |key, val|
  CLASSES[key] = val.map do |klass|
    Class === klass ? klass : Card::Chunk.const_get(klass)
  end
end

RENDERED = {
  :one => [
    "Some Literals: \\[{I'm not| a link]}, and ",
    "<span>{</span>{This Card|Is not Included}}",
    ", but ",
    {:options => {:inc_name=>"this is",:inc_syntax=>"this is"}},
    ", and some tail"
  ],
  :two => [
    "Some Links and includes: ",
    "<a class=\"wanted-card\" href=\"/the_card?card%5Bname%5D=the+card\">the text</a>",
    ", and ",
    { :options => { :view => "Is Included", :inc_name=>"This Card", :inc_syntax => "This Card|Is Included"}},
    { :options => { :inc_name=>"this too", :inc_syntax=>"this too"}},
    "\n        and ",
    "<a class=\"external-link\" href=\"http://external.wagn.org/path\">link text</a>",
    { :options => { :view=>"open", :inc_name=>"Included", :inc_syntax=>"Included|open" }}
  ],
  :three => [
    "Some URIs and Links: ", '<a class="external-link" href="http://a.url.com/">http://a.url.com/</a>',
    "\n        More urls: ",
    "<a class=\"external-link\" href=\"http://wagn.com/a/path/to.html\">wagn.com/a/path/to.html</a>",
    "\n        ",
    "<a class=\"external-link\" href=\"http://localhost:2020/path?cgi=foo&amp;bar=baz\">http://localhost:2020/path?cgi=foo&bar=baz</a>",
    "  ",
    "<a class=\"external-link\" href=\"http://brain.org/Home\">extra</a>",
    "\n        [ ",
    "<a class=\"external-link\" href=\"http://gerry.wagn.com/a/path\">http://gerry.wagn.com/a/path</a>",
    " ]\n        { ",
    "<a class=\"external-link\" href=\"https://brain.org/more?args\">https://brain.org/more?args</a>",
    " }"
  ],
  :three_b => [
    "Some URIs and Links: ","<a class=\"external-link\" href=\"http://a.url.com\">http://a.url.com</a>",
    "\n        More urls: ",
    "<a class=\"external-link\" href=\"http://wagn.com/a/path/to.html\">wagn.com/a/path/to.html</a>",
    "\n        [ ",
    "<a class=\"external-link\" href=\"http://gerry.wagn.com/a/path\">http://gerry.wagn.com/a/path</a>",
    " ]\n        { ",
    "<a class=\"external-link\" href=\"https://brain.org/more?args\">https://brain.org/more?args</a>",
    " }\n        ",
    "<a class=\"external-link\" href=\"http://localhost:2020/path?cgi=foo&amp;bar=baz\">http://localhost:2020/path?cgi=foo&bar=baz</a>",
    "  ",
    "<a class=\"external-link\" href=\"http://brain.org/Home\">extra</a>"
  ],
  :four => "No chunks"
}
TEXT_RENDERED = {
  :three => [
    "Some URIs and Links: ", 'http://a.url.com/',
    "\n        More urls: ",
    "wagn.com/a/path/to.html[http://wagn.com/a/path/to.html]",
    "\n        ",
    "http://localhost:2020/path?cgi=foo&bar=baz",
    "  ",
    "extra[http://brain.org/Home]",
    "\n        [ ",
    "http://gerry.wagn.com/a/path",
    " ]\n        { ",
    "https://brain.org/more?args",
    " }"
  ],
}

describe Card::Content do
  context "instance" do

    before do
      @check_proc = Proc.new do |m, v|
        if Array===m
          wrong_class = m[0] != v.class
          is_last = m.size == 1
          #warn "check M[#{is_last}]:#{wrong_class}, #{m[0]}, V#{v.inspect}" if wrong_class || is_last
          expect(wrong_class).to be_falsey
          wrong_class ? false : ( is_last ? true : m[1..-1] )
        else false end
      end

      assert card = Card["One"]
      @card = card

      # non-nil valued opts only ...
      @render_block =  Proc.new do |opts| {:options => opts.inject({}) {|i,v| !v[1].nil? && i[v[0]]=v[1]; i } } end
    end


    describe 'parse' do
      it "should find all the chunks and strings" do
        # note the mixed [} that are considered matching, needs some cleanup ...
        #warn "cont? #{CONTENT[:one].inspect}"
        cobj = Card::Content.new CONTENT[:one], @card
        expect(cobj.inject(CLASSES[:one], &@check_proc)).to eq(true)
      end

      it "should give just the chunks" do
        cobj = Card::Content.new CONTENT[:one], @card
        clist = CLASSES[:one].find_all {|c| String != c }
        #warn "clist #{clist.inspect}"
        cobj.each_chunk do |chk|
          expect(chk).to be_instance_of clist.shift
        end
        expect(clist).to be_empty
      end

      it "should find all the chunks links and trasclusions" do
        cobj = Card::Content.new CONTENT[:two], @card
        expect(cobj.inject(CLASSES[:two], &@check_proc)).to eq(true)
      end

      it "should find uri chunks " do
        # tried some tougher cases that failed, don't know the spec, so hard to form better tests for URIs here
        cobj = Card::Content.new CONTENT[:three], @card
        expect(cobj.inject(CLASSES[:three], &@check_proc)).to eq(true)
        clist = CLASSES[:three].find_all {|c| String != c }
        #warn "clist #{clist.inspect}, #{cobj.inspect}"
        cobj.each_chunk do |chk|
          expect(chk).to be_instance_of clist.shift
        end
        expect(clist).to be_empty
      end

      it "should find uri chunks (b)" do
        # tried some tougher cases that failed, don't know the spec, so hard to form better tests for URIs here
        cobj = Card::Content.new CONTENT[:three_b], @card
        #warn "cobj #{cobj.inspect} #{CLASSES[:three_b].inspect}"
        expect(cobj.inject(CLASSES[:three_b], &@check_proc)).to eq(true)
        clist = CLASSES[:three_b].find_all {|c| String != c }
        #warn "clist #{clist.inspect}, #{cobj.inspect}"
        cobj.each_chunk do |chk|
          expect(chk).to be_instance_of clist.shift
        end
        expect(clist).to be_empty
      end

      it "should parse just a string" do
        cobj = Card::Content.new CONTENT[:four], @card
        expect(cobj).to eq(RENDERED[:four])
      end

      it "should parse a single chunk" do
        cobj = Card::Content.new CONTENT[:five], @card
        expect(cobj.inject(CLASSES[:five], &@check_proc)).to eq(true)
        clist = CLASSES[:five].find_all {|c| String != c }
        cobj.each_chunk do |chk|
          expect(chk).to be_instance_of clist.shift
        end
        expect(clist).to be_empty
      end
    
      it "should leave css alone" do
        cobj = Card::Content.new CONTENT[:six], @card
        expect(cobj).to eq(CONTENT[:six])
      end
    end

    describe "render" do
      it "should render all includes" do
        cobj = Card::Content.new CONTENT[:one], @card
        expect(cobj.as_json.to_s).to match /not rendered/
        cobj.process_content_object &@render_block
        expect(rdr=cobj.as_json.to_json).not_to match /not rendered/
        expect(rdr).to eq(RENDERED[:one].to_json)
      end

      it "should render links and inclusions" do
        cobj = Card::Content.new CONTENT[:two], @card
        cobj.process_content_object &@render_block
        expect(rdr=cobj.as_json.to_json).not_to match /not rendered/
        expect(rdr).to eq(RENDERED[:two].to_json)
      end

      it "renders links correctly for text formatters" do
        card2 = Card[@card.id]
        format = card2.format :format => :text
        cobj = Card::Content.new CONTENT[:three], format
        cobj.process_content_object &@render_block
        expect(cobj.as_json.to_json).to eq(TEXT_RENDERED[:three].to_json)
      end

      it "should not need rendering if no inclusions" do
        cobj = Card::Content.new CONTENT[:three], @card
        cobj.process_content_object &@render_block
        expect(cobj.as_json.to_json).to eq(RENDERED[:three].to_json)
      end

      it "should not need rendering if no inclusions (b)" do
        cobj = Card::Content.new CONTENT[:three_b], @card
        expect(rdr=cobj.as_json.to_json).to match /not rendered/ # links are rendered too, but not with a block
        cobj.process_content_object &@render_block
        expect(rdr=cobj.as_json.to_json).not_to match /not rendered/
        expect(rdr).to eq(RENDERED[:three_b].to_json)
      end
    end
  end
  
  UNTAGGED_CASES = [ ' [grrew][/wiki/grrew]ss ', ' {{this is a test}}, {{this|view|is:too}} and',
    ' so is http://foo.bar.come//', ' and foo="my attr, not int a tag" <not a=tag ', ' p class"foobar"> and more' ]

  context "class" do
    describe '#clean!' do
      it 'should not alter untagged content' do
        UNTAGGED_CASES.each do |test_case|
          assert_equal test_case,Card::Content.clean!(test_case)
        end
      end
    
      it 'should strip disallowed html class attributes' do
        assert_equal '<p>html<div>with</div> funky tags</p>', Card::Content.clean!('<p>html<div class="boo">with</div><monkey>funky</butts>tags</p>')
        assert_equal '<span>foo</span>', Card::Content.clean!('<span class="banana">foo</span>')
      end

      it 'should not strip permitted_classes' do
        assert_equal '<span class="w-spotlight">foo</span>', Card::Content.clean!('<span class="w-spotlight">foo</span>')
        assert_equal '<p class="w-highlight w-ok">foo</p>', Card::Content.clean!('<p class="w-highlight w-ok">foo</p>')
      end

      it 'should strip permitted_classes but not permitted ones when both are present' do
        assert_equal "<span class='w-spotlight w-ok'>foo</span>", Card::Content.clean!("<span class='w-spotlight banana w-ok'>foo</span>")
        assert_equal '<p class="w-highlight">foo</p>', Card::Content.clean!('<p class="w-highlight bad-at end">foo</p>')
        assert_equal '<p class="w-highlight">foo</p>', Card::Content.clean!('<p class="bad-class w-highlight">foo</p>')
      end

      it 'should allow permitted attributes' do
        assert_equal '<img src="foo">',   Card::Content.clean!('<img src="foo">')
        assert_equal "<img alt='foo'>",   Card::Content.clean!("<img alt='foo'>")
        assert_equal '<img title="foo">', Card::Content.clean!('<img title=foo>')
        assert_equal '<a href="foo">',    Card::Content.clean!('<a href="foo">')
        assert_equal '<code lang="foo">', Card::Content.clean!('<code lang="foo">')
        assert_equal '<blockquote cite="foo">', Card::Content.clean!('<blockquote cite="foo">')
      end

      it 'should not allow nonpermitted attributes' do
        assert_equal '<img>', Card::Content.clean!('<img size="25">')
        assert_equal '<p>',   Card::Content.clean!('<p font="blah">')
      end

      it 'should remove comments' do
        assert_equal 'yo', Card::Content.clean!('<!-- not me -->yo')
        assert_equal 'joe', Card::Content.clean!('<!-- not me -->joe<!-- not me -->')
      end
    end
  end
  
  
end

