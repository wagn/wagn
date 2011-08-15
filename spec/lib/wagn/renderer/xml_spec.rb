require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../packs/pack_spec_helper'

describe Wagn::Renderer::Xml, "" do
  before do
    User.current_user = :joe_user
    Wagn::Renderer::Xml.current_slot = nil
  end
    
  def simplify_html string
    string.gsub(/\s*<!--[^>]*>\s*/, '').gsub(/\s*<\s*(\/?\w+)[^>]*>\s*/, '<\1>')
  end

#~~~~~~~~~~~~ special syntax ~~~~~~~~~~~#

  context "special syntax handling should render" do
    before do
      User.as :wagbot do
        @layout_card = Card.create(:name=>'tmp layout', :type=>'Html', :content=>"Mainly {{_main|naked}}")
        @layout_card.save
        c = Card['*all+*layout'] and c.content = '[[tmp layout]]'
      end
    end

    it "simple card links" do
      render_content("[[A]]").should=="<a class=\"known-card\" href=\"/wagn/A\">A</a>"
    end

    it "invisible comment inclusions as blank" do
      render_content("{{## now you see nothing}}").should==''
    end

    it "visible comment inclusions as html comments" do
      render_content("{{# now you see me}}").should == '<!-- # now you see me -->'
      render_content("{{# -->}}").should == '<!-- # --&gt; -->'
    end

    it "css in inclusion syntax in wrapper" do
      c = Card.new :name => 'Afloatright', :content => "{{A|float:right}}"
      Wagn::Renderer.new(c).render( :naked ).should be_html_with do
        div(:style => 'float:right;') {}
      end
    end

    # I want this test to show the explicit escaped HTML, but be_html_with seems to escape it already :-/
    it "HTML in inclusion systnax as escaped" do
      c =Card.new :name => 'Afloat', :type => 'Html', :content => '{{A|float:<object class="subject">}}'
      Wagn::Renderer::Xml.new(c).render( :naked ).should be_html_with do
        card(:style => 'float:<object class="subject">;') {}
      end
    end

    context "CGI variables" do
      it "substituted when present" do
        c = Card.new :name => 'cardNaked', :content => "{{_card+B|naked}}"
        result = Wagn::Renderer::Xml.new(c, :params=>{'_card' => "A"}).render_naked
        result.should == "AlphaBeta"
      end
    end

    it "renders layout card without recursing" do
      @layout_card.content="Mainly {{_main}}"
      User.as(:wagbot) { @layout_card.save }
      Wagn::Renderer::Xml.new(@layout_card).render(:layout).should be_html_with do
        body do
         p do
          text('Mainly ')
          card( :base=>"self", :type=>"HTML") do
            text('Mainly {{_main}}')
          end
         end
        end
      end
    end

  end

#~~~~~~~~~~~~ Error handling ~~~~~~~~~~~~~~~~~~#

  context "Error handling" do

    it "prevents infinite loops" do
      Card.create! :name => "n+a", :content=>"{{n+a|array}}"
      c = Card.new :name => 'naArray', :content => "{{n+a|array}}"
      Wagn::Renderer::Xml.new(c).render( :naked ).should =~ /too deep/
    end

    it "missing relative inclusion is relative" do
      c = Card.new :name => 'bad_include', :content => "{{+bad name missing}}"
      #Wagn::Renderer::Xml.new(c).render(:naked).match(Regexp.escape(%{Add <strong>+bad name missing</strong>})).should_not be_nil
      Wagn::Renderer::Xml.new(c).render(:naked) == %{Add <strong>+bad name missing</strong>}
    end

    it "renders deny for unpermitted cards" do
      User.as( :wagbot ) do
        Card.create(:name=>'Joe no see me', :type=>'Html', :content=>'secret')
        Card.create(:name=>'Joe no see me+*self+*read', :type=>'Pointer', :content=>'[[Administrator]]')
      end
      User.as :joe_user do
        Wagn::Renderer::Xml.new(Card.fetch('Joe no see me')).render(:naked).should be_html_with { no_card(:status=>"deny view") }
      end
    end      
  end

#~~~~~~~~~~~~~ Standard views ~~~~~~~~~~~~~~~~#
# (*all sets)


  context "handles view" do

    it("name"    ) { render_card(:name).should      == 'Tempo Rary' }
    it("key"     ) { render_card(:key).should       == 'tempo_rary' }
    it("linkname") { render_card(:linkname).should  == 'Tempo_Rary' }
    it("url"     ) { render_card(:url).should       == System.base_url + '/wagn/Tempo_Rary' }

    it "image tags of different sizes" do
      Card.create! :name => "TestImage", :type=>"Image", :content =>   %{<img src="http://wagn.org/image53_medium.jpg">}
      c = Card.new :name => 'Image1', :content => "{{TestImage | naked; size:small }}"
      Wagn::Renderer::Xml.new(c).render( :naked ).should == %{<img src="http://wagn.org/image53_small.jpg">}
    end

    describe "css classes" do
      it "are correct for open view" do
        c = Card.new :name => 'Aopen', :content => "{{A|open}}"
        Wagn::Renderer::Xml.new(c).render(:naked).should be_html_with do
          card( :class => "card-slot paragraph ALL TYPE-basic SELF-a") {}
        end
      end
    end

    it "naked" do
      render_card(:naked, :name=>'A+B').should == "AlphaBeta"
    end

    it "content" do
      render_card(:content, :name=>'A+B').should be_html_with {
        div( :class=>'transcluded ALL ALL_PLUS TYPE-basic RIGHT-b TYPE_PLUS_RIGHT-basic-b SELF-a-b', :home_view=>'content') {
          span( :class=>'content-content content')
        }
      }
    end

    it "titled" do
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
      result = Wagn::Renderer::Xml.new(c, :params=>{'_card' => "A"}).render_naked
      result.should == "AlphaBeta"
    end

    it "should not change name if variable isn't present" do
      c = Card.new :name => 'cardBname', :content => "{{_card+B|name}}"
      Wagn::Renderer::Xml.new(c).render( :naked ).should == "_card+B"
    end

    it "array (search card)" do
      Card.create! :name => "n+a", :type=>"Number", :content=>"10"
      Card.create! :name => "n+b", :type=>"Phrase", :content=>"say:\"what\""
      Card.create! :name => "n+c", :type=>"Number", :content=>"30"
      c = Card.new :name => 'nplusarray', :content => "{{n+*plus cards+by create|array}}"
      Wagn::Renderer::Xml.new(c).render( :naked ).should == %{["10", "say:\\"what\\"", "30"]}
    end

    it "array (pointer card)" do
      Card.create! :name => "n+a", :type=>"Number", :content=>"10"
      Card.create! :name => "n+b", :type=>"Number", :content=>"20"
      Card.create! :name => "n+c", :type=>"Number", :content=>"30"
      Card.create! :name => "npoint", :type=>"Pointer", :content => "[[n+a]]\n[[n+b]]\n[[n+c]]"
      c = Card.new :name => 'npointArray', :content => "{{npoint|array}}"
      Wagn::Renderer::Xml.new(c).render( :naked ).should == %q{["10", "20", "30"]}
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
      s.render( :naked ).should == "t2"

      # similar to above, but use link
      s = Wagn::Renderer.new(t, :inclusion_view_overrides=>{ :open => :link } )
      s.render( :naked ).should == "<a class=\"known-card\" href=\"/wagn/t2\">t2</a>"
      s = Wagn::Renderer.new(t, :inclusion_view_overrides=>{ :open => :naked } )
      s.render( :naked ).should == "boo"
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
      s.render( :naked ).should == "t2"

      # similar to above, but use link
      s = Wagn::Renderer.new(t, :inclusion_view_overrides=>{ :open => :link } )
      s.render( :naked ).should == "<a class=\"known-card\" href=\"/wagn/t2\">t2</a>"
      s = Wagn::Renderer.new(t, :inclusion_view_overrides=>{ :open => :naked } )
      s.render( :naked ).should == "boo"
    end
=end
 
    it "should render internal builtins" do
      render_card( :naked, :content=>%{
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
    Foot:{{*foot|naked}}
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
      Wagn::Renderer::Xml.new(template).render(:naked).should == '[[link]] {{inclusion}}'
    end

    it "skips *content if narrower *default is present" do  #this seems more like a settings test
      content_card = default_card = nil
      User.as :wagbot do
        content_card = Card.create!(:name=>"Phrase+*type+*content", :content=>"Content Foo" )
        default_card = Card.create!(:name=>"templated+*right+*default", :content=>"Default Bar" )
      end
      @card = Card.new( :name=>"test+templated", :type=>'Phrase' )
      @card.should_receive(:setting_card).with("content", "default").and_return(default_card)
      Wagn::Renderer::Xml.new(@card).render(:raw).should == "Default Bar"
    end

  end

#~~~~~~~~~~~~~~~ Cardtype Views ~~~~~~~~~~~~~~~~~#
# (type sets)

  context "cards of type" do
    context "Date" do
      it "should have special editor" do
        render_editor('Date').should be_html_with { a :class=>'date-editor-link'}
      end
    end

    context "File and Image" do
      #image calls the file partial, so in a way this tests both
      it "should have special editor" do
      #pending  #This test works fine alone but fails when run with others

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
        Card.create! :name => "TestImage", :type=>"Image", :content =>   %{<img src="http://wagn.org/image53_medium.jpg">}
        c = Card.new :name => 'Image1', :content => "{{TestImage | naked; size:small }}"
        Wagn::Renderer::Xml.new(c).render( :naked ).should == %{<img src="http://wagn.org/image53_small.jpg">}
      end
    end

    context "HTML" do
      before do
        User.current_user = :wagbot
      end

      it "should have special editor" do
        render_editor('Html').should be_html_with { textarea :rows=>'30' }
      end

      it "should not render any content in closed view" do
        render_card(:closed_content, :type=>'Html', :content=>"<strong>Lions and Tigers</strong>").should == ''
      end
    end

    context "Number" do
      it "should have special editor" do
        render_editor('Number').should be_html_with { input :type=>'text' }
      end
    end

    context "Phrase" do
      it "should have special editor" do
        render_editor('Phrase').should be_html_with { input :type=>'text', :class=>'phrasebox'}
      end
    end

    context "Plain Text" do
      it "should have special editor" do
        render_editor('Plain Text').should be_html_with { textarea :rows=>'3' }
      end

      it "should have special content that converts newlines to <br>'s" do
        render_card(:naked, :type=>'Plain Text', :content=>"a\nb").should == 'a<br/>b'
      end
    end

    context "Search" do
      it "should wrap search items with correct view class" do
        Card.create :type=>'Search', :name=>'Asearch', :content=>%{{"type":"User"}}        

        c=render_content("{{Asearch|naked;item:name}}")
        c.should match('search-result-item item-name')
        render_content("{{Asearch|naked;item:open}}").should match('search-result-item item-open')
        render_content("{{Asearch|naked}}").should match('search-result-item item-closed')
      end

      it "should handle returning 'count'" do
        render_card(:naked, :type=>'Search', :content=>%{{ "type":"User", "return":"count"}}).should == '10'
      end
    end

    context "Toggle" do
      it "should have special editor" do
        render_editor('Toggle').should be_html_with { input :type=>'checkbox' }
      end

      it "should have yes/no as processed content" do
        render_card(:naked, :type=>'Toggle', :content=>"0").should == 'no'
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
        render_card(:raw, :name=>'*version').match(/\d\.\d\.\d/ ).should_not be_nil
      end
    end

    context "*head" do
      it "should have a javascript tag" do
        render_card(:raw, :name=>'*head').should be_html_with { script :type=>'text/javascript' }
      end
    end

    context "*foot" do
      it "should have a javascript tag" do
        render_card(:raw, :name=>'*foot').should be_html_with { script :type=>'text/javascript' }
      end
    end

    context "*navbox" do
      it "should have a form" do
        render_card(:raw, :name=>'*navbox').should be_html_with { form :id=>'navbox_form' }
        #render_card(:raw, :name=>'*navbox').should == 'foobar'
      end
    end

    context "*account link" do
      it "should have a 'my card' link" do
        pending
        User.as :joe_user do
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
      render_content('{{+cardipoo|open}}').match(/Add \<strong\>\+cardipoo/ ).should_not be_nil
    end
  end


  context "replace refs" do
    before do
      User.current_user = :wagbot
    end
  
    it "replace references should work on inclusions inside links" do       
      card = Card.create!(:name=>"test", :content=>"[[test{{test}}]]"  )    
      assert_equal "[[test{{best}}]]", Wagn::Renderer::Xml.new(card).replace_references("test", "best" )
    end                                                                                                
  end

end
