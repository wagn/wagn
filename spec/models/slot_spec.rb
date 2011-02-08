require File.dirname(__FILE__) + '/../spec_helper'

describe Slot, "" do
  before { User.as :joe_user }
  def simplify_html string
    string.gsub(/\s*<!--[^>]*>\s*/, '').gsub(/\s*<\s*(\/?\w+)[^>]*>\s*/, '<\1>')
  end
  

  describe "processes content" do
    it "simple card links" do
      render_content("[[A]]").should=="<a class=\"known-card\" href=\"/wagn/A\">A</a>"
      Renderer.new(Card['A']).render_link().should=="<a class=\"known-card\" href=\"/wagn/A\">A</a>"
      Slot.new(Card['A']).render_link().should=="<a class=\"known-card\" href=\"/wagn/A\">A</a>"
    end

    it "invisible comment inclusions as blank" do
      render_content("{{## now you see nothing}}").should==''
    end
    
    it "missing relative inclusion is relative" do
      c = Card.new :name => 'bad_include', :content => "{{+bad name missing}}"
      Slot.new(c).render(:naked).match(Regexp.escape(%{Add <strong>+bad name missing</strong>})).should_not be_nil
    end
    
    it "visible comment inclusions as html comments" do
      render_content("{{# now you see me}}").should == '<!-- # now you see me -->'
      render_content("{{# -->}}").should == '<!-- # --&gt; -->'
    end

    it "renders name with layout" do
      c = Card.new :name => 'nameA', :content => "{{A|name}}"
      Slot.new(c, 'main_1').render_layout.should be_html_with do
        html { body { p {"A"} } }
      end
      c = Card.new :name => 'openA', :content => "{{A|open}}"
      Slot.new(c, :context=>'main_1', :view=>'open').render_layout.should be_html_with do
        body() {
          div(:class=>"title-menu") {
            a(:href=>"/wagn/A", :class=>"page-icon", :title=>"Go to: A") { }
          }
          span(:class=>"open-content content editOnDoubleClick") {
            a(:class=>"known-card", :href=>"/wagn/Z") { }
          }
        }
      end
    end

    it "renders layout card without recursing" do
      User.as :wagbot do
        layout_card = Card.create(:name=>'tmp layout', :type=>'Html', :content=>"Mainly {{_main|naked}}")
         Slot.new(layout_card).render(:layout, :main_card=>layout_card).should == %{Mainly <div id="main" context="main">Mainly {{_main|naked}}</div>}
       end
     end
 
     it "renders layout card elements" do
       User.as :wagbot do
         card = Card['A+B']
         layout_card = Card['Default Layout']
         Slot.new(layout_card).render(:layout, :main_card=>card).should == 
           '' ## should look for all the standard buildins
      end
    end

    it "renders deny" do
      restricted_card =
      User.as( :wagbot ) do
        card = Card.create(:name=>'Joe no see me', :type=>'Html', :content=>'secret')
        card.permit(:read, Role[:admin])
        card.save
        card
      end
      Slot.new(restricted_card).render(:core).should be_html_with { span(:class=>'denied') }
    end
    
    it "renders templates as raw" do
      template = Card.new(:name=>'A+*right+*content', :content=>'[[link]] {{inclusion}}')
      Slot.new(template).render(:naked).should == '[[link]] {{inclusion}}'
    end

    it "image tags of different sizes" do
      Card.create! :name => "TestImage", :type=>"Image", :content =>   %{<img src="http://wagn.org/image53_medium.jpg">}
      c = Card.new :name => 'Image1', :content => "{{TestImage | naked; size:small }}"
      Slot.new(c).render( :naked ).should == %{<img src="http://wagn.org/image53_small.jpg">}
    end

    describe "css classes" do
      it "are correct for open view" do
        c = Card.new :name => 'Aopen', :content => "{{A|open}}"
        Slot.new(c).render(:naked).should be_html_with do
          div( :class => "card-slot paragraph ALL TYPE-basic SELF-a") {}
        end
      end
    end

    describe "css in inclusion syntax" do
      it "shows up" do
        c = Card.new :name => 'Afloatright', :content => "{{A|float:right}}"
        Slot.new(c).render( :naked ).should be_html_with do
          div(:style => 'float:right;') {}
        end
      end

      # I want this test to show the explicit escaped HTML, but be_html_with seems to escape it already :-/
      it "shows up with escaped HTML" do
        c =Card.new :name => 'Afloat', :type => 'Html', :content => '{{A|float:<object class="subject">}}'
        Slot.new(c).render( :naked ).should be_html_with do
          div(:style => 'float:<object class="subject">;') {}
        end
      end
    end


    describe "inclusions" do
      it "multi edit" do
        c = Card.new :name => 'ABook', :type => 'Book'
        Slot.new(c).render( :multi_edit ).should be_html_with do
          div :class => "field-in-multi" do
            input :name=>"cards[~plus~illustrator][content]", :type => 'hidden'
          end
        end
      end
    end

    describe "views" do
      it "open" do
        mu = mock(:mu)
        mu.should_receive(:generate).and_return("1")
        UUID.should_receive(:new).and_return(mu)
        c = Card.new :name => 'Aopen', :content => "{{A|open}}"
        Slot.new(c).render( :naked ).should be_html_with do
          div( :position => 1, :class => "card-slot") {
            div( :class => "card-header" )
            span( :class => "content")  {
              #p "Alpha"
            }
          }
        end
      end

      it "array (basic card)" do
        render_card(:array, :name=>'boing', :content=>'yoing').should==%{["yoing"]}
      end
      
      it "naked" do
        c = Card.new :name => 'ABnaked', :content => "{{A+B|naked}}"
        Slot.new(c).render( :naked ).should == "AlphaBeta"
      end

      it "titled" do
        render_card(:titled, :name=>'A+B').should be_html_with do
          div( :view=>'titled') { 
            [ h1 { [ span{'A'}, span{'+'}, span{'B'} ] },
              span(:class=>'titled-content'){'AlphaBeta'}
            ] 
          }
        end
      end
      
      it("name"    ) { render_card(:name).should      == 'Tempo Rary' }
      it("key"     ) { render_card(:key).should       == 'tempo_rary' }
      it("linkname") { render_card(:linkname).should  == 'Tempo_Rary' }

      it "link" do
        c = Card.new :name => 'ABlink', :content => "{{A+B|link}}"
        Slot.new(c).render( :naked ).should == %{<a class="known-card" href="/wagn/A+B">A+B</a>}
      end

#Rails.logger.info "failing naked(search card) #{c_open}\nRenders:#{Slot.new(c_open).render_naked}\nRenders end"
      it "naked (search card)" do
       s = Card.create :type=>'Search', :name=>'Asearch', :content=>%{{"type":"User"}}
       cname = Card.new :name=>'AsearchNaked1',
                        :content=>"{{Asearch|naked;item:name}}"
       Slot.new(cname).render_naked.should match('search-result-item item-name')

       copen = Card.new :name => 'AsearchNaked1',
                        :content => "{{Asearch|naked;item:open}}"
       Slot.new(copen).render_naked.should match('search-result-item item-open')

       cclosed = Card.new :name => 'AsearchNaked',
                          :content => "{{Asearch|item:closed}}"
       Slot.new(cclosed).render_naked.should match('search-result-item item-closed')

       c = Card.new :name => 'AsearchNaked', :content => "{{Asearch|naked}}"
       Slot.new(c).render_naked.should match('search-result-item item-closed')
      end

      it "array (search card)" do
        Card.create! :name => "n+a", :type=>"Number", :content=>"10"
        Card.create! :name => "n+b", :type=>"Phrase", :content=>"say:\"what\""
        Card.create! :name => "n+c", :type=>"Number", :content=>"30"
        c = Card.new :name => 'nplusarray', :content => "{{n+*plus cards+by create|array}}"
        Slot.new(c).render( :naked ).should == %{["10", "say:\\"what\\"", "30"]}
      end

      it "array (pointer card)" do
        Card.create! :name => "n+a", :type=>"Number", :content=>"10"
        Card.create! :name => "n+b", :type=>"Number", :content=>"20"
        Card.create! :name => "n+c", :type=>"Number", :content=>"30"
        Card.create! :name => "npoint", :type=>"Pointer", :content => "[[n+a]]\n[[n+b]]\n[[n+c]]"
        c = Card.new :name => 'npointArray', :content => "{{npoint|array}}"
        Slot.new(c).render( :naked ).should == %q{["10", "20", "30"]}
      end

      it "array doesn't go in infinite loop" do
        Card.create! :name => "n+a", :content=>"{{n+a|array}}"
        c = Card.new :name => 'naArray', :content => "{{n+a|array}}"
        Slot.new(c).render( :naked ).should =~ /too deep/
      end
    end

    it "raw content" do
       @a = Card.new(:name=>'t', :content=>"{{A}}")
      Slot.new(@a).render(:raw).should == "{{A}}"
    end
  end

  describe "cgi params" do
    it "renders params in card inclusions" do
      c = Card.new :name => 'cardNaked', :content => "{{_card+B|naked}}"
      result = Slot.new(c, :params=>{'_card' => "A"}).render_naked
      result.should == "AlphaBeta"
    end

    it "should not change name if variable isn't present" do
      c = Card.new :name => 'cardBname', :content => "{{_card+B|name}}"
      Slot.new(c).render( :naked ).should == "_card+B"
    end
  end

  it "should use inclusion view overrides" do
    # FIXME love to have these in a scenario so they don't load every time.
    t = Card.create! :name=>'t1', :content=>"{{t2|card}}"
    Card.create! :name => "t2", :content => "{{t3|view}}"
    Card.create! :name => "t3", :content => "boo"

    # a little weird that we need :open_content  to get the version without
    # slot divs wrapped around it.
    s = Slot.new(t, :inclusion_view_overrides=>{ :open => :name } )
    s.render( :naked ).should == "t2"

    # similar to above, but use link
    s = Slot.new(t, :inclusion_view_overrides=>{ :open => :link } )
    s.render( :naked ).should == "<a class=\"known-card\" href=\"/wagn/t2\">t2</a>"

    s = Slot.new(t, :inclusion_view_overrides=>{ :open => :naked } )
    s.render( :naked ).should == "boo"
  end


  context "builtin card" do
    it "should render layout partial with name of card" do
      pending
      template = mock("template")
      template.should_receive(:render).with(:partial=>"builtin/builtin").and_return("Boo")
      builtin_card = Card.new( :name => "*builtin", :builtin=>true )
      slot = Slot.new( builtin_card )
      slot.render_raw.should == "Boo"
      slot.render(:raw).should == "Boo"
      slot = Slot.new( Card["*head"], "main_1", "view"  )
      slot.render(:naked).should == ''
    end
  end
 
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
</div>} ).should be_html_with do
      div {
        span(:name=>'head') do
          link(:rel=>'alternate', :title=>'Edit this page!', :href=>'/card/edit/*head') {}
        end
        # FIXME: can't figure out how to do a match on part of text
        #span(/^\s*#{Time.now.strftime('%A, %B %d, %Y')}/, :name=>'now') {}
        span( "Version:#{Wagn::Version.full}", :name=>'version') {}
        span(:name=>"foot") { script(:type=>"text/javascript") {} }
      }
    end
  end

  context "with content settings" do
    it "uses content setting" do
      pending
      @card = Card.new( :name=>"templated", :content => "bar" )
      config_card = Card.new(:name=>"templated+*self+*content", :content=>"Yoruba" )
      @card.should_receive(:setting_card).with("content","default").and_return(config_card)
      Slot.new(@card).render_raw.should == "Yoruba"
      @card.should_receive(:setting_card).with("content","default").and_return(config_card)
      @card.should_receive(:setting_card).with("add help","edit help")
      Slot.new(@card).render_new.should be_html_with do
        html { div(:class=>"unknown-class-name") {}}
      end
    end

    it "uses content and help setting in new" do
      content_card = Card.create!(:name=>"Phrase+*type+*content", :content=>"{{+Yoruba}}" )
      help_card    = Card.create!(:name=>"Phrase+*type+*add help", :content=>"Help me dude" )
      card = Card.new(:type=>'Phrase')
      card.should_receive(:setting_card).with("content","default").and_return(content_card)
      card.should_receive(:setting_card).with("add help","edit help").and_return(help_card)
      Slot.new(card).render_new.should be_html_with do
        div(:class=>"field-in-multi") {
          input :name=>"cards[~plus~Yoruba][content]", :type => 'hidden'
        }
      end
    end

    it "doesn't use content setting if default is present" do  #this seems more like a settings test
      content_card = Card.create!(:name=>"Phrase+*type+*content", :content=>"Content Foo" )
      default_card = Card.create!(:name=>"Phrase+*type+*default", :content=>"Default Bar" )
      @card = Card.new( :name=>"templated", :type=>'Phrase' )
      @card.should_receive(:setting_card).with("content", "default").and_return(default_card)
      Slot.new(@card).render(:raw).should == "Default Bar"
    end

    # FIXME: this test is important but I can't figure out how it should be
    # working.
    it "uses content setting in edit" do
      config_card = Card.create!(:name=>"templated+*self+*content", :content=>"{{+alpha}}" )
      @card = Card.new( :name=>"templated", :content => "Bar" )
      @card.should_receive(:setting_card).with("content", "default").and_return(config_card)
      result = Slot.new(@card).render(:edit)
      result.should be_html_with do
        div :class => "field-in-multi" do
          input :name=>"cards[~plus~alpha][content]", :type => 'hidden'
        end
      end
    end
  end

  describe "diff" do
    it "should not overwrite empty content with current" do
      pending # render_diff no longer exists, this is all in the changes partial now
      User.as(:wagbot)
      c = Card.create! :name=>"ChChChanges", :content => ""
      c.update_attributes :content => "A"
      c.update_attributes :content => "B"
      r = Slot.new(c).render_diff( c.revisions[0].content, c.revisions[1].content )
      r.should == "<ins class=\"diffins\">A</ins>"
    end
  end

  describe "Cards of type" do
    describe "Date" do
      it "should have special editor" do
        render_editor('Date').should be_html_with { a :class=>'date-editor-link'}
      end
    end

    describe "File and Image" do
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

    describe "HTML" do
      before do
        User.as :wagbot
      end
      
      it "should have special editor" do
        render_editor('Html').should be_html_with { textarea :rows=>'30' }
      end
      
      it "should not render any content in closed view" do
        render_card(:closed_content, :type=>'Html', :content=>"<strong>Lions and Tigers</strong>").should == ''
      end
    end
    
    describe "Account Request" do
      it "should have a special section for approving requests" do
        pending
        #I can't get this working.  I keep getting this url_for error -- from a line that doesn't call url_for
        card = Card.create!(:name=>'Big Bad Wolf', :type=>'Account Request')
        Slot.new(card).render(:naked).should be_html_with { div :class=>'invite-links' }
      end
    end

    describe "Number" do
      it "should have special editor" do
        render_editor('Number').should be_html_with { input :type=>'text' }
      end
    end
    
    describe "Phrase" do
      it "should have special editor" do
        render_editor('Phrase').should be_html_with { input :type=>'text', :class=>'phrasebox'}
      end
    end

    describe "Plain Text" do
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
    
    describe "Toggle" do
      it "should have special editor" do
        render_editor('Toggle').should be_html_with { input :type=>'checkbox' }
      end
      
      it "should have yes/no as processed content" do
        render_card(:naked, :type=>'Toggle', :content=>"0").should == 'no'
        render_card(:closed_content, :type=>'Toggle', :content=>"1").should == 'yes'
      end
    end

    
  end
  
  def render_editor(type)
    card = Card.create(:name=>"my favority #{type} + rand(4)", :type=>type)
    Slot.new(card).render(:edit)
  end
  
  def render_content(content, view=:naked)
    @card ||= Card.new
    @card.content=content
    Slot.new(@card).render(view)
  end

  def render_card(view, card_args={})
    card_args[:name] ||= "Tempo Rary"
    card = Card.new(card_args.merge(:skip_defaults=>true))
    Slot.new(card).render(view)
  end
  
  
end

