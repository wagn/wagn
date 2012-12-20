require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../packs/pack_spec_helper'

describe Wagn::Renderer::Xml, "" do
  before do
    Wagn::Conf[:base_url] = nil
    Account.user= :joe_user
    Wagn::Renderer::Xml.current_slot = nil
  end

#~~~~~~~~~~~~ special syntax ~~~~~~~~~~~#

  context "special syntax handling should render" do
    #before do
    #  Account.as_bot do
    #  end
    #end

    it "simple card links" do
      xml_render_content("[[A]]").should=="<cardlink class=\"known-card\" card=\"/A\">A</cardlink>"
    end

    it "invisible comment inclusions as blank" do
      xml_render_content("{{## now you see nothing}}").should==''
    end

    it "visible comment inclusions as html comments" do
      xml_render_content("{{# now you see me}}").should == '<!-- # now you see me -->'
      xml_render_content("{{# -->}}").should == '<!-- # --&gt; -->'
    end

    it "css in inclusion syntax in wrapper" do
      c = Card.new :name => 'Afloatright', :content => "{{A|float:right}}"
      data=Wagn::Renderer.new(c)._render( :core )
      assert_view_select data, 'div[style="float:right;"]'
    end

    # I want this test to show the explicit escaped HTML, but be_html_with seems to escape it already :-/
    it "HTML in inclusion systnax as escaped" do
      c =Card.new :name => 'Afloat', :type => 'Html', :content => '{{A|float:<object class="subject">}}'
      data=Wagn::Renderer::Xml.new(c)._render( :core )
      #warn "data is #{data}"
      assert_view_select data, %{card[style="float:&amp;lt;object class=&amp;quot;subject&amp;quot;&amp;gt;;"]}
    end

    context "CGI variables" do
      it "substituted when present" do
        c = Card.new :name => 'cardNaked', :content => "{{_card+B|naked}}"
        result = Wagn::Renderer::Xml.new(c, :params=>{'_card' => "A"})._render_core
        result.should == "AlphaBeta"
      end
    end

  end

#~~~~~~~~~~~~ Error handling ~~~~~~~~~~~~~~~~~~#

  context "Error handling" do

    it "prevents infinite loops" do
      Card.create! :name => "n+a", :content=>"{{n+a|array}}"
      c = Card.new :name => 'naArray', :content => "{{n+a|array}}"
      Wagn::Renderer::Xml.new(c)._render( :core ).should =~ /too deep/
    end

    it "missing relative inclusion is relative" do
      c = Card.new :name => 'bad_include', :content => "{{+bad name missing}}"
      Wagn::Renderer::Xml.new(c)._render(:core).should match /^<no_card .*\"missing\".*bad_include\+bad name missing/
    end

    it "renders deny for unpermitted cards" do
      pending "with html"
      Account.as_bot do
        Card.create(:name=>'Joe no see me', :type=>'Html', :content=>'secret')
        Card.create(:name=>'Joe no see me+*self+*read', :type=>'Pointer', :content=>'[[Administrator]]')
      end
      Account.as :joe_user do
        Wagn::Renderer::Xml.new(Card.fetch('Joe no see me')).render(:core).should be_html_with { no_card(:status=>"deny view") }
      end
    end
  end

#~~~~~~~~~~~~~ Standard views ~~~~~~~~~~~~~~~~#
# (*all sets)


  context "handles view" do

    it("name"    ) { render_card(:name).should      == 'Tempo Rary' }
    it("key"     ) { render_card(:key).should       == 'tempo_rary' }
    it("linkname") { render_card(:linkname).should  == 'Tempo_Rary' }
    it("url"     ) { render_card(:url).should       == '/Tempo_Rary' }

    it "should handle size argument in inclusion syntax" do
      image_card = Card.create! :name => "TestImage", :type=>"Image", :content => %{TestImage.jpg\nimage/jpeg\n12345}
      including_card = Card.new :name => 'Image1', :content => "{{TestImage | core; size:small }}"
      rendered = Wagn::Renderer::Xml.new(including_card)._render :core
      assert_view_select rendered, 'img[src=?]', "/files/TestImage-small-#{image_card.current_revision_id}.jpg"
    end

    describe "css classes" do
      it "are correct for open view" do
        c = Card.new :name => 'Aopen', :content => "{{A|open}}"
        Wagn::Renderer::Xml.new(c)._render(:core).should match /<card cardId="\d+" class="card-slot paragraph ALL TYPE-basic SELF-a view-open" home_view="open" name="A" style="" type_id="3">Alpha <cardlink class="known-card" card="\/Z">Z<\/cardlink><\/card>/
      end
    end

    it "naked" do
      render_card(:core, :name=>'A+B').should == "AlphaBeta"
    end

    it "content" do
      pending "with html"
      render_card(:content, :name=>'A+B').should be_html_with {
        div( :class=>'transcluded ALL ALL_PLUS TYPE-basic RIGHT-b TYPE_PLUS_RIGHT-basic-b SELF-a-b', :home_view=>'content') {
          span( :class=>'content-content content')
        }
      }
    end

    it "titled" do
      pending "with html"
      render_card(:titled, :name=>'A+B').should be_html_with do
        div( :home_view=>'titled') {
          [ h1 { [ span{'A'}, span{'+'}, span{'B'} ] },
            span(:class=>'titled-content'){'AlphaBeta'}
          ]
        }
      end
    end
  end

  describe "cgi params" do
    it "renders params in card inclusions" do
      c = Card.new :name => 'cardNaked', :content => "{{_card+B|naked}}"
      result = Wagn::Renderer::Xml.new(c, :params=>{'_card' => "A"})._render_core
      result.should == "AlphaBeta"
    end

    it "should not change name if variable isn't present" do
      c = Card.new :name => 'cardBname', :content => "{{_card+B|name}}"
      Wagn::Renderer::Xml.new(c)._render( :core ).should == "_card+B"
    end

    it "array (search card)" do
      Card.create! :name => "n+a", :type=>"Number", :content=>"10"
      Card.create! :name => "n+b", :type=>"Phrase", :content=>"say:\"what\""
      Card.create! :name => "n+c", :type=>"Number", :content=>"30"
      c = Card.new :name => 'nplusarray', :content => "{{n+*plus cards+by create|array}}"
      Wagn::Renderer::Xml.new(c)._render( :core ).should == %{["10", "say:\\"what\\"", "30"]}
    end

    it "array (pointer card)" do
      Card.create! :name => "n+a", :type=>"Number", :content=>"10"
      Card.create! :name => "n+b", :type=>"Number", :content=>"20"
      Card.create! :name => "n+c", :type=>"Number", :content=>"30"
      Card.create! :name => "npoint", :type=>"Pointer", :content => "[[n+a]]\n[[n+b]]\n[[n+c]]"
      c = Card.new :name => 'npointArray', :content => "{{npoint|array}}"
      Wagn::Renderer::Xml.new(c)._render( :core ).should == %q{["10", "20", "30"]}
    end

=begin
    it "should use inclusion view overrides" do
      # FIXME love to have these in a scenario so they don't load every time.
      t = Card.create! :name=>'t1', :content=>"{{t2|card}}"
      Card.create! :name => "t2", :content => "{{t3|view}}"
      Card.create! :name => "t3", :content => "boo"

      # a little weird that we need :open_content  to get the version without
      # slot divs wrapped around it.
      s = Wagn::Renderer.new(t, :inclusion_view_overrides=>{ :open => :name } )
      s.render( :core ).should == "t2"

      # similar to above, but use link
      s = Wagn::Renderer.new(t, :inclusion_view_overrides=>{ :open => :link } )
      s.render( :core ).should == "<a class=\"known-card\" href=\"/wagn/t2\">t2</a>"
      s = Wagn::Renderer.new(t, :inclusion_view_overrides=>{ :open => :core } )
      s.render( :core ).should == "boo"
    end
=end
  end

  context "builtin card" do
=begin
    it "should use inclusion view overrides" do
      # FIXME love to have these in a scenario so they don't load every time.
      t = Card.create! :name=>'t1', :content=>"{{t2|card}}"
      Card.create! :name => "t2", :content => "{{t3|view}}"
      Card.create! :name => "t3", :content => "boo"

      # a little weird that we need :open_content  to get the version without
      # slot divs wrapped around it.
      s = Wagn::Renderer.new(t, :inclusion_view_overrides=>{ :open => :name } )
      s.render( :core ).should == "t2"

      # similar to above, but use link
      s = Wagn::Renderer.new(t, :inclusion_view_overrides=>{ :open => :link } )
      s.render( :core ).should == "<a class=\"known-card\" href=\"/wagn/t2\">t2</a>"
      s = Wagn::Renderer.new(t, :inclusion_view_overrides=>{ :open => :core } )
      s.render( :core ).should == "boo"
    end
=end

    it "should render internal builtins" do
      pending "with html"
      render_card( :core, :content=>%{
<div>
  <span name="head">
    Head:{{*head|naked}}
  </span>
  <span name="now">
    Now:{{*now}}
  </span>
  <span name="version">
    Version:{{*version|naked}}
  </span>
  <span name="foot">
    Foot:{{*foot|core}}
  </span>
</div>} ).should be_html_with   do
        div {
          span(:name=>'head')    { }
          span(:name=>'now') {
            div(:home_view=>'content') {
              span() { text(Time.now.strftime('%A, %B %d, %Y %I:%M %p %Z')) }
            }
          }
          span(:name=>'version') { "Version:#{Wagn::Version.full}" }
          span(:name=>"foot")    { script(:type=>"text/javascript") {} }
        }
      end
    end
  end

#~~~~~~~~~~~~~  content views
# includes some *right stuff


  context "Content settings" do
    it "are rendered as raw" do
      template = Card.new(:name=>'A+*right+*content', :content=>'[[link]] {{inclusion}}')
      Wagn::Renderer::Xml.new(template)._render(:core).should == '[[link]] {{inclusion}}'
    end

    it "skips *content if narrower *default is present" do  #this seems more like a settings test
      pending
      content_card = default_card = nil
      Account.as_bot do
        content_card = Card.create!(:name=>"Phrase+*type+*content", :content=>"Content Foo" )
        default_card = Card.create!(:name=>"templated+*right+*default", :content=>"Default Bar" )
      end
      @card = Card.new( :name=>"test+templated", :type=>'Phrase' )
      mock(@card).rule_card(:content, :default).returns(default_card)
      Wagn::Renderer::Xml.new(@card).render(:raw).should == "Default Bar"
    end

  end

#~~~~~~~~~~~~~~~ Cardtype Views ~~~~~~~~~~~~~~~~~#
# (type sets)

  context "cards of type" do
    context "Date" do
      it "should have special editor" do
        data=xml_render_card(:link,:type=>'Date')
        #warn "data = #{data}"
        assert_view_select data, 'cardlink[class="wanted-card"]'
      end
    end

    context "File and Image" do
      pending "with html"
      #image calls the file partial, so in a way this tests both
      it "should have special editor" do
      pending  #This test works fine alone but fails when run with others

        render_editor('Image').should be_html_with do
          body do  ## this is weird -- why does it have a body?
            [div(:class=>'attachment-preview'),
              div { iframe :class=>'upload-iframe'}
            ]
          end
        end
      end
    end

    context "Image" do
      it "should handle size argument in inclusion syntax" do
        Card.create! :name => "TestImage", :type=>"Image",
          :content => %{TestImage.jpg\nimage/jpeg\n12345}
        c = Card.new :name => 'Image1',
             :content => "{{TestImage | naked; size:small }}"
        Wagn::Renderer::Xml.new(c)._render( :core ).should match %r{^<img alt="Testimage-small-\d+" src="/files/TestImage-small-\d+\.jpg" />$}
      end
    end

    context "HTML" do
      before do
        Account.user= Card::WagnBotID
      end

      it "should have special editor" do
      pending "with html"
        render_editor('Html').should be_html_with { textarea :rows=>'30' }
      end

      it "should not render any content in closed view" do
        render_card(:closed_content, :type=>'Html', :content=>"<strong>Lions and Tigers</strong>").should == ''
      end
    end

    context "Number" do
      it "should have special editor" do
      pending "with html"
        render_editor('Number').should be_html_with { input :type=>'text' }
      end
    end

    context "Phrase" do
      it "should have special editor" do
      pending "with html"
        render_editor('Phrase').should be_html_with { input :type=>'text', :class=>'phrasebox'}
      end
    end

    context "Plain Text" do
      it "should have special editor" do
      pending "with html"
        render_editor('Plain Text').should be_html_with { textarea :rows=>'3' }
      end

      it "should have special content that escapes HTML" do
        render_card(:core, :type=>'Plain Text', :content=>"<b></b>").should == '&lt;b&gt;&lt;/b&gt;'
      end
    end

    context "Search" do
      it "should wrap search items with correct view class" do
        pending "this is not yet default behavior"
        Card.create :type=>'Search', :name=>'Asearch', :content=>%{{"type":"User"}}

        c=xml_render_content("{{Asearch|naked;item:name}}")
        c.should match('search-result-item item-name')
        xml_render_content("{{Asearch|naked;item:open}}").should match('search-result-item item-open')
        xml_render_content("{{Asearch|naked}}").should match('search-result-item item-closed')
      end

      it "should handle returning 'count'" do
        render_card(:core, :type=>'Search', :content=>%{{ "type":"User", "return":"count"}}).should == '10'
      end
    end

    context "Toggle" do
      it "should have special editor" do
      pending "with html"
        render_editor('Toggle').should be_html_with { input :type=>'checkbox' }
      end

      it "should have yes/no as processed content" do
        render_card(:core, :type=>'Toggle', :content=>"0").should == 'no'
        render_card(:closed_content, :type=>'Toggle', :content=>"1").should == 'yes'
      end
    end
  end


  # ~~~~~~~~~~~~~~~~~ Builtins Views ~~~~~~~~~~~~~~~~~~~
  # ( *self sets )


  context "builtin card" do
    context "*now" do
      it "should have a date" do
        render_card(:raw, :name=>'*now').match(/\w+day, \w+ \d+, \d{4}/ ).should_not be_nil
      end
    end

    context "*version" do
      it "should have an X.X.X version" do
        render_card(:raw, :name=>'*version').
          match(/\d\.\d+\.\w+/ ).should_not be_nil
      end
    end

    context "*head" do
      it "should have a javascript tag" do
      pending "with html"
        render_card(:raw, :name=>'*head').should be_html_with { script :type=>'text/javascript' }
      end
    end

    context "*foot" do
      it "should have a javascript tag" do
      pending "with html"
        render_card(:raw, :name=>'*foot').should be_html_with { script :type=>'text/javascript' }
      end
    end

    context "*navbox" do
      it "should have a form" do
      pending "with html"
        render_card(:raw, :name=>'*navbox').should be_html_with { form :id=>'navbox_form' }
        #render_card(:raw, :name=>'*navbox').should == 'foobar'
      end
    end

    context "*account link" do
      it "should have a 'my card' link" do
        pending
        Account.as :joe_user do
          render_card(:raw, :name=>'*account links').should be_html_with { span( :id=>'logging' ) {
              a( :id=>'my-card-link') { 'My Card: Joe User' }
            }
          }
        end
      end
    end

    # also need one for *alerts
  end


#~~~~~~~~~ special views

  context "open missing" do
    it "should use the showname" do
      xml_render_content('{{+cardipoo|open}}').match(/\<no_card status=\"missing\"\>Tempo Rary 2\+cardipoo\<\/no_card\>/ ).should_not be_nil
    end
  end


  context "replace refs" do
    before do
      Account.user= Card::WagnBotID
    end

    it "replace references should work on inclusions inside links" do
      card = Card.create!(:name=>"test", :content=>"[[test{{test}}]]"  )
      assert_equal "[[test{{best}}]]", Wagn::Renderer::Xml.new(card).replace_references("test", "best" )
    end
  end

end
