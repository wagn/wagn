require File.dirname(__FILE__) + '/../spec_helper'

describe Slot do
  before { User.as :joe_user }
  def simplify_html string
    string.gsub(/\s*<!--[^>]*>\s*/, '').gsub(/\s*<\s*(\/?\w+)[^>]*>\s*/, '<\1>')
  end
  
#~~~~~~~~~~~~ special syntax ~~~~~~~~~~~#

  context "special syntax handling should render" do
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
      Slot.new(c).render( :naked ).should be_html_with do
        div(:style => 'float:right;') {}
      end
    end

    # I want this test to show the explicit escaped HTML, but be_html_with seems to escape it already :-/
    it "HTML in inclusion systnax as escaped" do
      c =Card.new :name => 'Afloat', :type => 'Html', :content => '{{A|float:<object class="subject">}}'
      Slot.new(c).render( :naked ).should be_html_with do
        div(:style => 'float:<object class="subject">;') {}
      end
    end
    
    context "CGI variables" do
      it "substituted when present" do
        c = Card.new :name => 'cardNaked', :content => "{{_card+B|naked}}"
        result = Slot.new(c, :params=>{'_card' => "A"}).render_naked
        result.should == "AlphaBeta"
      end

      it "not substituted when absent" do
        c = Card.new :name => 'cardBname', :content => "{{_card+B|name}}"
        Slot.new(c).render( :naked ).should == "_card+B"
      end
    end
    
  end


#~~~~~~~~~~~~ Error handling ~~~~~~~~~~~~~~~~~~#

  context "Error handling" do
    
    it "prevents infinite loops" do
      Card.create! :name => "n+a", :content=>"{{n+a|array}}"
      c = Card.new :name => 'naArray', :content => "{{n+a|array}}"
      Slot.new(c).render( :naked ).should =~ /too deep/
    end
    
    it "missing relative inclusion is relative" do
      c = Card.new :name => 'bad_include', :content => "{{+bad name missing}}"
      Slot.new(c).render(:naked).match(Regexp.escape(%{Add <strong>+bad name missing</strong>})).should_not be_nil
    end
    
    it "renders deny for unpermitted cards" do
      restricted_card =
      User.as( :wagbot ) do
        card = Card.create(:name=>'Joe no see me', :type=>'Html', :content=>'secret')
        card.permit(:read, Role[:admin])
        card.save
        card
      end
      Slot.new(restricted_card).render(:core).should be_html_with { span(:class=>'denied') }
    end      
  end




     






#~~~~~~~~~~~~~ Standard views ~~~~~~~~~~~~~~~~#
# (*all sets)


  context "handles view" do

    it("name"    ) { render_card(:name).should      == 'Tempo Rary' }
    it("key"     ) { render_card(:key).should       == 'tempo_rary' }
    it("linkname") { render_card(:linkname).should  == 'Tempo_Rary' }

    it "link" do
      render_card(:link, :name=>'A+B').should == %{<a class="known-card" href="/wagn/A+B">A+B</a>}
    end

    it "raw" do
      render_content('{{A}}', :raw).should == "{{A}}"
    end
    
    it "naked" do
      render_card(:naked, :name=>'A+B').should == "AlphaBeta"
    end

    it "content" do
      render_card(:content, :name=>'A+B').should be_html_with {
        div( :class=>'transcluded ALL TYPE-basic RIGHT-b TYPE_PLUS_RIGHT-basic-b SELF-a-b', :view=>'content') {
          span( :class=>'content-content content')
        }
      }
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
    


    context "full wrapping" do
      before do
        mu = mock(:mu)
        mu.should_receive(:generate).and_return("1")
        UUID.should_receive(:new).and_return(mu)
        @ocslot = Slot.new(Card['A'])
      end
      
      it "should have the appropriate attributes on open" do
        @ocslot.render_open.should be_html_with do
          div( :position => 1, :view=>'open', :class => "card-slot paragraph ALL TYPE-basic SELF-a") {
            [ div( :class => "card-header" ) { div( :class=>'title-menu')},
              span( :class => "open-content content")  { }
            ]
          }
        end
      end
      
      it "should have the appropriate attributes on closed" do
        @ocslot.render_closed.should be_html_with do
          div( :position => 1, :view=>'closed', :class => "card-slot line ALL TYPE-basic SELF-a") {
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
    
    

    context "layout" do
      before do
        @layout_card = Card.create(:name=>'tmp layout')
        @main_card = Card.fetch('Joe User')
      end

      it "should default to naked view for non-main inclusions when context is layout_0" do
        @layout_card.content = "Hi {{A}}"
        Slot.new(@layout_card, :context=>'layout_0').render(:layout).should match('Hi Alpha')
      end

      it "should default to open view for main card" do
        @layout_card.content='Open up {{_main}}'
        result = Slot.new(@layout_card).render(:layout, :main_card=>@main_card)
        result.should match(/Open up/)
        result.should match(/card-header/)
        result.should match(/Joe User/)
      end  
      
      it "should render custom view of main" do
        @layout_card.content='Hey {{_main|name}}'
        result = Slot.new(@layout_card).render(:layout, :main_card=>@main_card)
        result.should match(/Hey.*div.*Joe User/)
        result.should_not match(/card-header/)
      end

      it "shouldn't recurse" do
        @layout_card.content="Mainly {{_main|naked}}"
        Slot.new(@layout_card).render(:layout, :main_card=>@layout_card).should == %{Mainly <div id="main" context="main">Mainly {{_main|naked}}</div>}
      end

      it "should handle non-card content" do
        @layout_card.content='Hello {{_main}}'
        result = Slot.new(@layout_card).render(:layout, :main_content=>'and Goodbye')
        result.should match(/Hello.*and Goodbye/)
      end
        
       #  it "renders layout card elements" do
       #    User.as :wagbot do
       #      card = Card['A+B']
       #      layout_card = Card['Default Layout']
       #      Slot.new(layout_card).render(:layout, :main_card=>card).should be html_with '' ## should look for all the standard buildins
       #      end
       #    end

    end

    it "array (basic card)" do
      render_card(:array, :content=>'yoing').should==%{["yoing"]}
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



  end



#~~~~~~~~~~~~~  content views 
# includes some *right stuff 


  context "Content settings" do
    it "are rendered as raw" do
      template = Card.new(:name=>'A+*right+*content', :content=>'[[link]] {{inclusion}}')
      Slot.new(template).render(:naked).should == '[[link]] {{inclusion}}'
    end
    
    
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

    it "are used in new card forms" do
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

    it "skips *content if *default is present" do  #this seems more like a settings test
      content_card = Card.create!(:name=>"Phrase+*type+*content", :content=>"Content Foo" )
      default_card = Card.create!(:name=>"Phrase+*type+*default", :content=>"Default Bar" )
      @card = Card.new( :name=>"templated", :type=>'Phrase' )
      @card.should_receive(:setting_card).with("content", "default").and_return(default_card)
      Slot.new(@card).render(:raw).should == "Default Bar"
    end

    # FIXME: this test is important but I can't figure out how it should be
    # working.
    it "are used in edit forms" do
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
    
    it "are used in multi edit calls" do
      c = Card.new :name => 'ABook', :type => 'Book'
      Slot.new(c).render( :multi_edit ).should be_html_with do
        div :class => "field-in-multi" do
          input :name=>"cards[~plus~illustrator][content]", :type => 'hidden'
        end
      end
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
        Slot.new(c).render( :naked ).should == %{<img src="http://wagn.org/image53_small.jpg">}
      end
    end
    

    context "HTML" do
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
    
    context "Account Request" do
      it "should have a special section for approving requests" do
        pending
        #I can't get this working.  I keep getting this url_for error -- from a line that doesn't call url_for
        card = Card.create!(:name=>'Big Bad Wolf', :type=>'Account Request')
        Slot.new(card).render(:naked).should be_html_with { div :class=>'invite-links' }
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
        
        render_content("{{Asearch|naked;item:name}}").should match('search-result-item item-name')
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

  end  
  

#~~~~~~~~~  HELPER METHODS ~~~~~~~~~~~~~~~#
  
  def render_editor(type)
    card = Card.create(:name=>"my favority #{type} + rand(4)", :type=>type)
    Slot.new(card).render(:edit)
  end
  
  def render_content(content, view=:naked)
    @card ||= Card.new(:name=>"Tempo Rary 2", :skip_defaults=>true)
    @card.content=content
    Slot.new(@card).render(view)
  end

  def render_card(view, card_args={})
    card = begin
      if card_args[:name]
        Card.fetch(card_args[:name])
      else
        card_args[:name] ||= "Tempo Rary"
        card = Card.new(card_args.merge(:skip_defaults=>true))
      end
    end
    Slot.new(card).render(view)
  end
  
  
end


#  describe "diff" do
#    it "should not overwrite empty content with current" do
#      pending # render_diff no longer exists, this is all in the changes partial now
#      User.as(:wagbot)
#      c = Card.create! :name=>"ChChChanges", :content => ""
#      c.update_attributes :content => "A"
#      c.update_attributes :content => "B"
#      r = Slot.new(c).render_diff( c.revisions[0].content, c.revisions[1].content )
#      r.should == "<ins class=\"diffins\">A</ins>"
#    end
#  end




