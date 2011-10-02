require_relative '../../spec_helper'
require_relative '../../packs/pack_spec_helper'

describe Wagn::Renderer, "" do
  before do
    User.current_user = :joe_user
    Wagn::Renderer.current_slot = nil
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
      Wagn::Renderer.new(c).render( :naked ).should be_html_with do
        div(:style => 'float:<object class="subject">;') {}
      end
    end

    context "CGI variables" do
      it "substituted when present" do
        c = Card.new :name => 'cardNaked', :content => "{{_card+B|naked}}"
        result = Wagn::Renderer.new(c, :params=>{'_card' => "A"}).render_naked
        result.should == "AlphaBeta"
      end
    end

    it "renders layout card without recursing" do
      Wagn::Renderer.new(@layout_card).render(:layout).should == %{Mainly <div id="main" context="main">Mainly {{_main|naked}}</div>}
    end

  end

#~~~~~~~~~~~~ Error handling ~~~~~~~~~~~~~~~~~~#

  context "Error handling" do

    it "prevents infinite loops" do
      Card.create! :name => "n+a", :content=>"{{n+a|array}}"
      c = Card.new :name => 'naArray', :content => "{{n+a|array}}"
      Wagn::Renderer.new(c).render( :naked ).should =~ /too deep/
    end

    it "missing relative inclusion is relative" do
      c = Card.new :name => 'bad_include', :content => "{{+bad name missing}}"
      Wagn::Renderer.new(c).render(:naked).match(Regexp.escape(%{Add <strong>+bad name missing</strong>})).should_not be_nil
    end

    it "renders deny for unpermitted cards" do
      User.as( :wagbot ) do
        Card.create(:name=>'Joe no see me', :type=>'Html', :content=>'secret')
        Card.create(:name=>'Joe no see me+*self+*read', :type=>'Pointer', :content=>'[[Administrator]]')
      end
      User.as :joe_user do
        Wagn::Renderer.new(Card.fetch('Joe no see me')).render(:naked).should be_html_with { span(:class=>'denied') }
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
      Wagn::Renderer.new(c).render( :naked ).should == %{<img src="http://wagn.org/image53_small.jpg">}
    end

    describe "css classes" do
      it "are correct for open view" do
        c = Card.new :name => 'Aopen', :content => "{{A|open}}"
        Wagn::Renderer.new(c).render(:naked).should be_html_with do
          div( :class => "card-slot paragraph ALL TYPE-basic SELF-a") {}
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

    describe "inclusions" do
      it "multi edit" do
        c = Card.new :name => 'ABook', :type => 'Book'
        Wagn::Renderer.new(c).render( :multi_edit ).should be_html_with do
          div :class => "field-in-multi" do
            input :name=>"cards[~plus~illustrator][content]", :type => 'hidden'
          end
        end
      end
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

    context "full wrapping" do
      before do
        mu = mock(:mu)
        mu.should_receive(:generate).and_return("1")
        UUID.should_receive(:new).and_return(mu)
        @ocslot = Wagn::Renderer.new(Card['A'])
      end

      it "should have the appropriate attributes on open" do
        @ocslot.render(:open).should be_html_with do
          div( :position => 1, :home_view=>'open', :class => "card-slot paragraph ALL TYPE-basic SELF-a") {
            [ div( :class => "card-header" ) { div( :class=>'title-menu')},
              span( :class => "open-content content")  { }
            ]
          }
        end
      end

      it "should have the appropriate attributes on closed" do
        Rails.logger.debug "\nBEFORE TEST~~~~~~~~~~~~~~~~~~~~~~~~~\n"
        @ocslot.render(:closed).should be_html_with do
          div( :position => 1, :home_view=>'closed', :class => "card-slot line ALL TYPE-basic SELF-a") {
            [ div( :class => "card-header" ) { div( :class=>'title-menu')},
              span( :class => "closed-content content")  { }
            ]
          }
        end
      end

      it "should add javascript when requested" do
        @ocslot.render(:closed, :add_javascript=>true).should match('script type="text/javascript"')
      end
    end

    context "Simple page with Default Layout" do
      before do
        User.as :wagbot do
          card = Card['A+B']
          @simple_page = Wagn::Renderer::RichHtml.new(card).render(:layout)
        end
      end


# looks like be_html_with does weird things with head and body??
#      it "renders body with id" do
#        @simple_page.should be_html_with do
#          body(:id=>"wagn") {}
#        end
#      end
#
#      it "renders head" do
#        @simple_page.should be_html_with do
#          head() {
#            title() {
#              text('- My Wagn')
#            }
#          }
#        end
#      end

      it "renders top menu" do
        @simple_page.should be_html_with do
          div(:id=>"menu") {
            a(:class=>"internal-link", :href=>"/") { 'Home' }
            a(:class=>"internal-link", :href=>"/recent") { 'Recent' }

          #<div base=\"self\" class=\"transcluded ALL TYPE-basic\" position=\"545d0f2\" style=\"\" view=\"content\">
            form(:id=>"navbox_form", :action=>"/search") {
              a(:id=>"navbox_image", :title=>"Search") {}
              input(:name=>"navbox") {}
            }
          }
        end
      end

      it "renders card header" do
        @simple_page.should be_html_with do
          a(:href=>"/wagn/A+B", :class=>"page-icon", :title=>"Go to: A+B") {}
        end
      end

      it "renders card content" do
        @simple_page.should be_html_with do
          span(:class=>"open-content content editOnDoubleClick") { 'AlphaBeta' }
        end
      end

      it "renders notice info" do
        @simple_page.should be_html_with do
          span(:class=>"notice") {}
        end
      end

      it "renders card footer" do
        @simple_page.should be_html_with do
          div(:class=>"card-footer") {
            span(:class=>"watch-link") {
              a(:title=>"get emails about changes to A+B") { "watch" }
            }
          }
        end
      end

      it "renders card credit" do
        @simple_page.should be_html_with do
          div(:id=>"credit") { [ "Wheeled by", a() { 'Wagn' } ] }
        end
      end
    end

    context "layout" do
      before do
        @layout_card = Card.create(:name=>'tmp layout')
        c = Card['*all+*layout'] and c.content = '[[tmp layout]]'
        @main_card = Card.fetch('Joe User')
      end

      it "should default to naked view for non-main inclusions when context is layout_0" do
        @layout_card.content = "Hi {{A}}"
        @layout_card.save
        Wagn::Renderer.new(@main_card).render(:layout).should match('Hi Alpha')
      end

      it "should default to open view for main card" do
        @layout_card.content='Open up {{_main}}'
        @layout_card.save
        result = Wagn::Renderer.new(@main_card).render_layout
        result.should match(/Open up/)
        result.should match(/card-header/)
        result.should match(/Joe User/)
      end

      it "should render custom view of main" do
        @layout_card.content='Hey {{_main|name}}'
        @layout_card.save
        result = Wagn::Renderer.new(@main_card).render_layout
        result.should match(/Hey.*div.*Joe User/)
        result.should_not match(/card-header/)
      end

      it "shouldn't recurse" do
        @layout_card.content="Mainly {{_main|naked}}"
        @layout_card.save
        Wagn::Renderer.new(@layout_card).render(:layout).should == %{Mainly <div id="main" context="main">Mainly {{_main|naked}}</div>}
      end

      it "should handle non-card content" do
        @layout_card.content='Hello {{_main}}'
        @layout_card.save
        result = Wagn::Renderer.new(nil).render(:layout, :main_content=>'and Goodbye')
        result.should match(/Hello.*and Goodbye/)
      end

    end

    it "raw content" do
      @a = Card.new(:name=>'t', :content=>"{{A}}")
      Wagn::Renderer.new(@a).render(:raw).should == "{{A}}"
    end

    it "array (basic card)" do
      render_card(:array, :content=>'yoing').should==%{["yoing"]}
    end
  end

  describe "cgi params" do
    it "renders params in card inclusions" do
      c = Card.new :name => 'cardNaked', :content => "{{_card+B|naked}}"
      result = Wagn::Renderer.new(c, :params=>{'_card' => "A"}).render_naked
      result.should == "AlphaBeta"
    end

    it "should not change name if variable isn't present" do
      c = Card.new :name => 'cardBname', :content => "{{_card+B|name}}"
      Wagn::Renderer.new(c).render( :naked ).should == "_card+B"
    end

    it "array (search card)" do
      Card.create! :name => "n+a", :type=>"Number", :content=>"10"
      Card.create! :name => "n+b", :type=>"Phrase", :content=>"say:\"what\""
      Card.create! :name => "n+c", :type=>"Number", :content=>"30"
      c = Card.new :name => 'nplusarray', :content => "{{n+*plus cards+by create|array}}"
      Wagn::Renderer.new(c).render( :naked ).should == %{["10", "say:\\"what\\"", "30"]}
    end

    it "array (pointer card)" do
      Card.create! :name => "n+a", :type=>"Number", :content=>"10"
      Card.create! :name => "n+b", :type=>"Number", :content=>"20"
      Card.create! :name => "n+c", :type=>"Number", :content=>"30"
      Card.create! :name => "npoint", :type=>"Pointer", :content => "[[n+a]]\n[[n+b]]\n[[n+c]]"
      c = Card.new :name => 'npointArray', :content => "{{npoint|array}}"
      Wagn::Renderer.new(c).render( :naked ).should == %q{["10", "20", "30"]}
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
              span() { Time.now.strftime('%A, %B %d, %Y %I:%M %p %Z') }
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
      Wagn::Renderer.new(template).render(:naked).should == '[[link]] {{inclusion}}'
    end


    it "uses content setting" do
      pending
      @card = Card.new( :name=>"templated", :content => "bar" )
      config_card = Card.new(:name=>"templated+*self+*content", :content=>"Yoruba" )
      @card.should_receive(:setting_card).with("content","default").and_return(config_card)
      Wagn::Renderer.new(@card).render_raw.should == "Yoruba"
      @card.should_receive(:setting_card).with("content","default").and_return(config_card)
      @card.should_receive(:setting_card).with("add help","edit help")
      Wagn::Renderer.new(@card).render_new.should be_html_with do
        html { div(:class=>"unknown-class-name") {}}
      end
    end

    it "are used in new card forms" do
      User.as :joe_admin
      content_card = Card.create!(:name=>"Cardtype E+*type+*content", :content=>"{{+Yoruba}}" )
      help_card    = Card.create!(:name=>"Cardtype E+*type+*add help", :content=>"Help me dude" )
      card = Card.new(:type=>'Cardtype E')
      card.should_receive(:setting_card).with("autoname").and_return(nil)
      card.should_receive(:setting_card).with("content","default").and_return(content_card)
      card.should_receive(:setting_card).with("add help","edit help").and_return(help_card)
      Wagn::Renderer::RichHtml.new(card).render_new.should be_html_with do
        div(:class=>"field-in-multi") {
          input :name=>"cards[~plus~Yoruba][content]", :type => 'hidden'
        }
      end
    end

    it "skips *content if narrower *default is present" do  #this seems more like a settings test
      User.as :wagbot do
        content_card = Card.create!(:name=>"Phrase+*type+*content", :content=>"Content Foo" )
        default_card = Card.create!(:name=>"templated+*right+*default", :content=>"Default Bar" )
      end
      @card = Card.new( :name=>"test+templated", :type=>'Phrase' )
      Wagn::Renderer.new(@card).render(:raw).should == "Default Bar"
    end


    it "should be used in edit forms" do
      User.as :wagbot do
        config_card = Card.create!(:name=>"templated+*self+*content", :content=>"{{+alpha}}" )
      end
      @card = Card.fetch('templated')# :name=>"templated", :content => "Bar" )
      @card.content = 'Bar'
      result = Wagn::Renderer.new(@card).render(:edit)
      result.should be_html_with do
        div :class => "field-in-multi" do
          input :name=>"cards[templated~plus~alpha][content]", :type => 'hidden'
        end
      end
    end

    it "work on type-plus-right sets edit calls" do
      User.as :wagbot do
        Card.create(:name=>'Book+author+*type plus right+*default', :type=>'Phrase', :content=>'Zamma Flamma')
      end
      c = Card.new :name=>'Yo Buddddy', :type=>'Book'
      result = Wagn::Renderer::RichHtml.new(c).render( :multi_edit )
      result.should be_html_with do
        div :class => "field-in-multi" do
          [ input( :name=>"cards[~plus~author][content]",  :type=>'text',   :value=>'Zamma Flamma' ),
            input( :name=>"cards[~plus~author][typecode]", :type=>'hidden', :value=>'Phrase'       )  ]
        end
      end
      result.should match('Zamma Flamma')
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
        Card.create! :name => "TestImage", :type=>"Image", :content =>   %{<img src="http://wagn.org/image53_medium.jpg">}
        c = Card.new :name => 'Image1', :content => "{{TestImage | naked; size:small }}"
        Wagn::Renderer.new(c).render( :naked ).should == %{<img src="http://wagn.org/image53_small.jpg">}
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

    context "Account Request" do
      it "should have a special section for approving requests" do
        pending
        #I can't get this working.  I keep getting this url_for error -- from a line that doesn't call url_for
        card = Card.create!(:name=>'Big Bad Wolf', :type=>'Account Request')
        Wagn::Renderer.new(card).render(:naked).should be_html_with { div :class=>'invite-links' }
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

      it "should have special content that escapes HTML" do
        pending
        render_card(:naked, :type=>'Plain Text', :content=>"<b></b>").should == '&lt;b&gt;&lt;/b&gt;'
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
      assert_equal "[[test{{best}}]]", Wagn::Renderer.new(card).replace_references("test", "best" )
    end
  end

end
