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


     #banner {
       border-bottom: 5px solid #3260a0;
     }

     #banner img {
       /* float: left; */
     }

     #bannerlinks {
       float: right;
       padding-top: 5px;
     }

     #logging {
       position: relative;
       right: 0px;
       top: 0px;
       display: block;
       padding-right: 25px;
       padding-bottom: 10px;
     }


     .navbox-form {
       position: relative;
       display: block;
       width: 350px;
     }

     .navbox, #navbox:focus {
       width: 80%;
     }


     /* card headers etc */
     .card-header {
       background: #ffffff;
     }
     .card-header,
     .card-header a:link {
       font-weight: normal;
       color: #666666; 
       font-size: 0.9em;
     }

     /*
     #menu a:hover, .card-header a:hover {
       background: #3260a0;
     }
     */

     /* misc */

     .card-footer, 
     .revision-navigation, 
     .current,
     #credit {
       background: #DDDDDD;
     }

     /* arb css */
     body a:link, body a:visited {
       color:#3754D4;
     }

     body a:hover {
       background-color:#ECECE7;
       color:#C84B13;
     }





     .card-header .title-menu a:link {
       color:#253B5A;
       font-size:1.1em;
       font-weight:bold;
       margin:14px 0 12px;
       padding-bottom:1px;
       width:100%;
     }

     .card-header {
       border-bottom: 1px dashed #cccccc;
     }

     .TYPE-concept .w-right_title {
       border-bottom:1px dotted #999999;
       color:#253B5A;
       font-size:1.5em;
       font-weight:bold;
       margin:14px 0 12px;
       padding-bottom:1px;
       width:100%;
     }

     h1 {
       color:#911F1F;
       font-variant:normal;
       margin:0.9em 0 0;
     }

     /* column container */
     .colmask {
       position:relative;		/* This fixes the IE7 overflow hidden bug and stops the layout jumping out of place */
       clear:both;
       float:left;
       width:100%;			/* width of whole page */
       overflow:hidden;	/* This chops off any overhanging divs */
     }
     /* 2 column left menu settings */
     .leftmenu {
       background:#CCD4DF;
     }
     .leftmenu .colright {
       float:left;
       width:200%;
       position:relative;
       left:200px;
       background:#fff;
     }
     .leftmenu .col1wrap {
       float:right;
       width:50%;
       position:relative;
       right:200px;
       padding-bottom:1em;
     }
     .leftmenu .col1 {
       margin:0 15px 0 215px;
       position:relative;
       right:100%;
       overflow:hidden;
     }
     .leftmenu .col2 {
       float:left;
       width:170px;
       position:relative;
       right:185px;
     }
     /* Footer styles */
     #footer {
       clear:both;
       float:left;
       width:100%;
       border-top:1px solid #000;
     }
     #footer p {
       padding:10px;
       margin:0;
     }
     body {
         margin:0;
         padding:0;
         border:0;			/* This removes the border around the viewport in old versions of IE */
         width:100%;
         background:#fff;
         min-width:600px;    /* Minimum width of layout - remove line if not required */
     					/* The min-width property does not work in old versions of Internet Explorer */
     font-size:90%;
     }

   ~
}

CLASSES = {
   :one => [String, Literal::Escape, String, Literal::Escape, String, Chunks::Include, String ],
   :two => [String, Chunks::Link, String, Chunks::Include, Chunks::Include, String, Chunks::Link, String, Chunks::Link, Chunks::Link, Chunks::Include ],
   :three => [String, URIChunk, String, URIChunk, String, URIChunk, String, LocalURIChunk, String, LocalURIChunk, String, Chunks::Link ],
   :five => [Chunks::Include]
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
    Account.authorized_id = Card['joe_user'].id
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
    
    it "should leave css alone" do
      cobj = ObjectContent.new CONTENT[:six], @card_opts
      cobj.should == CONTENT[:six]
    end
  end

  describe "render" do
    it "should render all includes" do
      cobj = ObjectContent.new CONTENT[:one], @card_opts
      cobj.as_json.to_s.should match /not rendered/
      cobj.process_content_object &@render_block
      (rdr=cobj.as_json.to_json).should_not match /not rendered/
      rdr.should == RENDERED[:one].to_json
    end

    it "should render links and inclusions" do
      cobj = ObjectContent.new CONTENT[:two], @card_opts
      cobj.process_content_object &@render_block
      (rdr=cobj.as_json.to_json).should_not match /not rendered/
      rdr.should == RENDERED[:two].to_json
    end

    it "should not need rendering if no inclusions" do
      cobj = ObjectContent.new CONTENT[:three], @card_opts
      (rdr=cobj.as_json.to_json).should match /not rendered/ # links are rendered too, but not with a block
      cobj.process_content_object &@render_block
      (rdr=cobj.as_json.to_json).should_not match /not rendered/
      rdr.should == RENDERED[:three].to_json
    end
  end
end

