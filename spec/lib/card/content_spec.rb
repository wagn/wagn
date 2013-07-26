# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'
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
    "<a class=\"wanted-card\" href=\"/the%20card\">the text</a>", #"[[the card|the text]]",
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
    "<a class=\"external-link\" href=\"http://localhost:2020/path?cgi=foo&bar=baz\">http://localhost:2020/path?cgi=foo&bar=baz</a>",
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
    "<a class=\"external-link\" href=\"http://localhost:2020/path?cgi=foo&bar=baz\">http://localhost:2020/path?cgi=foo&bar=baz</a>",
    "  ",
    "<a class=\"external-link\" href=\"http://brain.org/Home\">extra</a>"
  ],
  :four => "No chunks"
}

describe Card::Content do

  before do

    @check_proc = Proc.new do |m, v|
      if Array===m
        wrong_class = m[0] != v.class
        is_last = m.size == 1
        #warn "check M[#{is_last}]:#{wrong_class}, #{m[0]}, V#{v.inspect}" if wrong_class || is_last
        wrong_class.should be_false
        wrong_class ? false : ( is_last ? true : m[1..-1] )
      else false end
    end

    Account.current_id = Card['joe_user'].id
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
      cobj.inject(CLASSES[:one], &@check_proc).should == true
    end

    it "should give just the chunks" do
      cobj = Card::Content.new CONTENT[:one], @card
      clist = CLASSES[:one].find_all {|c| String != c }
      #warn "clist #{clist.inspect}"
      cobj.each_chunk do |chk|
        chk.should be_instance_of clist.shift
      end
      clist.should be_empty
    end

    it "should find all the chunks links and trasclusions" do
      cobj = Card::Content.new CONTENT[:two], @card
      cobj.inject(CLASSES[:two], &@check_proc).should == true
    end

    it "should find uri chunks " do
      # tried some tougher cases that failed, don't know the spec, so hard to form better tests for URIs here
      cobj = Card::Content.new CONTENT[:three], @card
      cobj.inject(CLASSES[:three], &@check_proc).should == true
      clist = CLASSES[:three].find_all {|c| String != c }
      #warn "clist #{clist.inspect}, #{cobj.inspect}"
      cobj.each_chunk do |chk|
        chk.should be_instance_of clist.shift
      end
      clist.should be_empty
    end

    it "should find uri chunks (b)" do
      # tried some tougher cases that failed, don't know the spec, so hard to form better tests for URIs here
      cobj = Card::Content.new CONTENT[:three_b], @card
      #warn "cobj #{cobj.inspect} #{CLASSES[:three_b].inspect}"
      cobj.inject(CLASSES[:three_b], &@check_proc).should == true
      clist = CLASSES[:three_b].find_all {|c| String != c }
      #warn "clist #{clist.inspect}, #{cobj.inspect}"
      cobj.each_chunk do |chk|
        chk.should be_instance_of clist.shift
      end
      clist.should be_empty
    end

    it "should parse just a string" do
      cobj = Card::Content.new CONTENT[:four], @card
      cobj.should == RENDERED[:four]
    end

    it "should parse a single chunk" do
      cobj = Card::Content.new CONTENT[:five], @card
      cobj.inject(CLASSES[:five], &@check_proc).should == true
      clist = CLASSES[:five].find_all {|c| String != c }
      cobj.each_chunk do |chk|
        chk.should be_instance_of clist.shift
      end
      clist.should be_empty
    end
    
    it "should leave css alone" do
      cobj = Card::Content.new CONTENT[:six], @card
      cobj.should == CONTENT[:six]
    end
  end

  describe "render" do
    it "should render all includes" do
      cobj = Card::Content.new CONTENT[:one], @card
      cobj.as_json.to_s.should match /not rendered/
      cobj.process_content_object &@render_block
      (rdr=cobj.as_json.to_json).should_not match /not rendered/
      rdr.should == RENDERED[:one].to_json
    end

    it "should render links and inclusions" do
      cobj = Card::Content.new CONTENT[:two], @card
      cobj.process_content_object &@render_block
      (rdr=cobj.as_json.to_json).should_not match /not rendered/
      rdr.should == RENDERED[:two].to_json
    end

    it "should not need rendering if no inclusions" do
      cobj = Card::Content.new CONTENT[:three], @card
#      (rdr=cobj.as_json.to_json).should match /not rendered/ # links are rendered too, but not with a block
      cobj.process_content_object &@render_block
      (rdr=cobj.as_json.to_json) #.should_not match /not rendered/
      rdr.should == RENDERED[:three].to_json
    end

    it "should not need rendering if no inclusions (b)" do
      cobj = Card::Content.new CONTENT[:three_b], @card
      (rdr=cobj.as_json.to_json).should match /not rendered/ # links are rendered too, but not with a block
      cobj.process_content_object &@render_block
      (rdr=cobj.as_json.to_json).should_not match /not rendered/
      rdr.should == RENDERED[:three_b].to_json
    end
  end
end

