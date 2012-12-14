require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'object_content'

CONTENT = {
  :one => %(Some Literals: \\[{I'm not| a link]}, and \\{{This Card|Is not Included}}, but {{this is}}, and some tail),
  :two => %(Some Links and includes: [[the card|the text]], and {{This Card|Is Included}}{{this too}}
         more formats for links and includes: [the card][the text],
         and [[http://external.wagn.org/path|link text]][This Card][Is linked]{{Included|open}}),
  :three => %(Some Literals: http://a.url.com
        More urls: wagn.com/a/path/to.html
        [ http://gerry.wagn.com/a/path ]
        { https://brain/more?args }
        http://localhost:2020/path?cgi=foo&bar=baz  [[http://brain/Home|extra]]),
   :four => "No chunks",
   :five => "{{one inclusion|size;large}}"
}

CLASSES = {
   :one => [String, Literal::Escape, String, Literal::Escape, String, Chunk::Include, String ],
   :two => [String, Chunk::Link, String, Chunk::Include, Chunk::Include, String, Chunk::Link, String, Chunk::Link, Chunk::Link, Chunk::Include ],
   :three => [String, URIChunk, String, URIChunk, String, URIChunk, String, LocalURIChunk, String, LocalURIChunk, String, Chunk::Link ],
   :five => [Chunk::Include]
}

RENDERED = {
  :one => ['Some Literals: ', "[<span>{</span>I'm not| a link]}", ", and ", "<span>{</span>{This Card|Is not Included}}", ", but ",
            {:options => {:tname=>"this is",:include=>"this is",:style=>''}}, ", and some tail" ],
  :two => ["Some Links and includes: ", "<a class=\"wanted-card\" href=\"/the%20card\">the text</a>", #"[[the card|the text]]",
     ", and ", {:options => {:tname=>"This Card", :view => "Is Included",:include => "This Card|Is Included",:style=>""}},{
      :options=>{:tname=>"this too",:include=>"this too",:style=>""}},
    "\n         more formats for links and includes: ","<a class=\"wanted-card\" href=\"/the%20text\">the card</a>",
    ",\n         and ","<a class=\"external-link\" href=\"http://external.wagn.org/path\">link text</a>",
    "<a class=\"wanted-card\" href=\"/Is%20linked\">This Card</a>",
    {:options=>{:tname=>"Included",:view=>"open",:include=>"Included|open",:style=>""}}],
  :three => ["Some Literals: ","<a class=\"external-link\" href=\"http://a.url.com\">http://a.url.com</a>","\n        More urls: ",
    "<a class=\"external-link\" href=\"http://wagn.com/a/path/to.html\">wagn.com/a/path/to.html</a>",
    "\n        [ ","<a class=\"external-link\" href=\"http://gerry.wagn.com/a/path\">http://gerry.wagn.com/a/path</a>",
    " ]\n        { ","<a class=\"external-link\" href=\"https://brain/more?args\">https://brain/more?args</a>"," }\n        ",
    "<a class=\"external-link\" href=\"http://localhost:2020/path?cgi=foo&bar=baz\">http://localhost:2020/path?cgi=foo&bar=baz</a>", "  ",
    "<a class=\"external-link\" href=\"http://brain/Home\">extra</a>"],
  :four => "No chunks"
}

describe ObjectContent do

  before do
    Account.user= 'joe_user'
    assert card = Card["One"]
    @card_opts = {
      :card => card,
      :renderer => Wagn::Renderer.new(card)
    }

    # non-nil valued opts only ...
    @render_block =  Proc.new do |opts| {:options => opts.inject({}) {|i,v| !v[1].nil? && i[v[0]]=v[1]; i } } end
    @check_classes = Proc.new do |m, v|
        if Array===m
          v.should be_instance_of m[0]
          m[0] != v.class ? false : m.size == 1 ? true : m[1..-1]
        else false end
      end
  end


  describe 'parse' do
    it "should find all the chunks and strings" do
      # note the mixed [} that are considered matching, needs some cleanup ...
      cobj = ObjectContent.new CONTENT[:one], @card_opts
      cobj.inject(CLASSES[:one], &@check_classes).should == true
    end

    it "should give just the chunks" do
      cobj = ObjectContent.new CONTENT[:one], @card_opts
      clist = CLASSES[:one].find_all {|c| String != c }
      cobj.each_chunk do |chk|
        chk.should be_instance_of clist.shift
      end
      clist.should be_empty
    end

    it "should find all the chunks links and trasclusions" do
      cobj = ObjectContent.new CONTENT[:two], @card_opts
      cobj.inject(CLASSES[:two], &@check_classes).should == true
    end

    it "should find uri chunks " do
      # tried some tougher cases that failed, don't know the spec, so hard to form better tests for URIs here
      cobj = ObjectContent.new CONTENT[:three], @card_opts
      cobj.inject(CLASSES[:three], &@check_classes).should == true
      clist = CLASSES[:three].find_all {|c| String != c }
      cobj.each_chunk do |chk|
        chk.should be_instance_of clist.shift
      end
      clist.should be_empty
    end

    it "should parse just a string" do
      cobj = ObjectContent.new CONTENT[:four], @card_opts
      cobj.should == RENDERED[:four]
    end

    it "should parse a single chunk" do
      cobj = ObjectContent.new CONTENT[:five], @card_opts
      cobj.inject(CLASSES[:five], &@check_classes).should == true
      clist = CLASSES[:five].find_all {|c| String != c }
      cobj.each_chunk do |chk|
        chk.should be_instance_of clist.shift
      end
      clist.should be_empty
    end
  end

  describe "render" do
    it "should render all includes" do
      cobj = ObjectContent.new CONTENT[:one], @card_opts
      cobj.as_json.to_s.should match /not rendered/
      cobj.process_content &@render_block
      (rdr=cobj.as_json.to_json).should_not match /not rendered/
      rdr.should == RENDERED[:one].to_json
    end

    it "should render links and inclusions" do
      cobj = ObjectContent.new CONTENT[:two], @card_opts
      cobj.process_content &@render_block
      (rdr=cobj.as_json.to_json).should_not match /not rendered/
      rdr.should == RENDERED[:two].to_json
    end

    it "should not need rendering if no inclusions" do
      cobj = ObjectContent.new CONTENT[:three], @card_opts
      (rdr=cobj.as_json.to_json).should match /not rendered/ # links are rendered too, but not with a block
      cobj.process_content &@render_block
      (rdr=cobj.as_json.to_json).should_not match /not rendered/
      rdr.should == RENDERED[:three].to_json
    end
  end
end

