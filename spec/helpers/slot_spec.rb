require File.dirname(__FILE__) + '/../spec_helper'

describe Slot, "" do      
  before { User.as :joe_user }   
  describe "renders" do
    it "simple card links" do
      Slot.render_content( "[[A]]" ).should == "<a class=\"known-card\" href=\"/wagn/A\">A</a>"  
    end
    
    it "invisible comment inclusions as blank" do
      Slot.render_content( "{{## now you see nothing}}" ).should == ''
    end
    
    it "visible comment inclusions as html comments" do
      Slot.render_content( "{{# now you see me}}" ).should == '<!-- # now you see me -->'
      Slot.render_content( "{{# -->}}" ).should == '<!-- # --&gt; -->'
    end  
    
    it "image tags of different sizes" do
      Card.create! :name => "TestImage", :type=>"Image", :content =>   %{<img src="http://wagn.org/image53_medium.jpg">}
      Slot.render_content( "{{TestImage | naked; size:small }}" ).should == %{<img src="http://wagn.org/image53_small.jpg">} 
    end

    describe "css classes" do
      it "are correct for open view" do
        Slot.render_content("{{A|open}}").should be_html_with do
          div( :class => "card-slot paragraph ALL TYPE-basic SELF-a") {}
        end
      end
    end
    
    describe "views" do
      it "open" do
        mu = mock(:mu)
        mu.should_receive(:generate).and_return("1")
        UUID.should_receive(:new).and_return(mu)
        Slot.render_content("{{A|open}}").should be_html_with do
          div( :position => 1, :class => "card-slot") {
            div( :class => "card-header" )
            span( :class => "content")  {
              #p "Alpha"
            }
          }
        end
      end
      
      it "naked" do
        Slot.render_content("{{A+B|naked}}").should == "AlphaBeta"
      end
      
      it "array (basic card)" do
        Slot.render_content("{{A+B|array}}").should == %{["AlphaBeta"]}
      end
      
      it "array (search card)" do
        Card.create! :name => "n+a", :type=>"Number", :content=>"10"
        Card.create! :name => "n+b", :type=>"Phrase", :content=>"say:\"what\""
        Card.create! :name => "n+c", :type=>"Number", :content=>"30"
        Slot.render_content("{{n+*plus cards|array}}").should == %{["10", "say:\\"what\\"", "30"]}
      end

      it "array (pointer card)" do
        Card.create! :name => "n+a", :type=>"Number", :content=>"10"
        Card.create! :name => "n+b", :type=>"Number", :content=>"20"
        Card.create! :name => "n+c", :type=>"Number", :content=>"30"
        Card.create! :name => "npoint", :type=>"Pointer", :content => "[[n+a]]\n[[n+b]]\n[[n+c]]"
        Slot.render_content("{{npoint|array}}").should == %q{["10", "20", "30"]}
      end

      it "array doesn't go in infinite loop" do        
        Card.create! :name => "n+a", :content=>"{{n+a|array}}"
        Slot.render_content("{{n+a|array}}").should =~ /Oops\!/
      end
    end
    
    it "raw content" do
       @a = Card.new(:name=>'t', :content=>"{{A}}")
      Slot.new(@a).render(:naked_content).should == "{{A}}"
    end                                                                                      
  end
  
  describe "cgi params" do
    it "renders params in card inclusions" do
      result = Slot.render_content("{{_card+B|naked}}", :params=>{'_card' => "A"})
      result.should == "AlphaBeta"
    end
    
    it "should not change name if variable isn't present" do
      Slot.render_content("{{_card+B|name}}").should == "_card+B"
    end
  end

  it "should use inclusion view overrides" do  
    # FIXME love to have these in a scenario so they don't load every time.
    t = Card.create! :name=>'t1', :content=>"{{t2|card}}"
    Card.create! :name => "t2", :content => "{{t3|view}}" 
    Card.create! :name => "t3", :content => "boo" 
    
    # a little weird that we need :expanded_view_content  to get the version without
    # slot divs wrapped around it.
    s = Slot.new(t, "main_1", "view", nil, :inclusion_view_overrides=>{ :open => :name } )
    s.render( :expanded_view_content ).should == "t2"
    
    s = Slot.new(t, "main_1", "view", nil, :inclusion_view_overrides=>{ :open => :expanded_view_content } )
    s.render( :expanded_view_content ).should == "boo"
  end
  
  context "builtin card" do
    it "should render layout partial with name of card" do     
      template = mock("template")
      template.should_receive(:render).with(:partial=>"builtin/builtin").and_return("Boo")
      builtin_card = Card.new( :name => "*builtin", :builtin=>true )
      slot = Slot.new( builtin_card, "main_1", "view", template  ) 
      slot.render(:naked_content).should == "Boo"
    end
  end

  context "with content settings" do
    it "uses content setting" do
      @card = Card.new( :name=>"templated", :content => "bar" )
      config_card = Card.new(:name=>"templated+*self+*content", :content=>"Yoruba" )
      @card.should_receive(:setting_card).with("content","default").and_return(config_card)
      Slot.new(@card).render(:naked_content).should == "Yoruba"
    end
    
    it "doesn't use content setting if default is present" do
      @card = Card.new( :name=>"templated", :content => "Bar" )
      config_card = Card.new(:name=>"templated+*self+*default", :content=>"Yoruba" )
      @card.should_receive(:setting_card).with("content", "default").and_return(config_card)
      Slot.new(@card).render(:naked_content).should == "Bar"
    end
    
    # FIXME: this test is important but I can't figure out how it should be 
    # working.
    it "uses content setting in edit" do
      pending
      config_card = Card.create!(:name=>"templated+*self+*content", :content=>"{{+alpha}}" )
      @card = Card.new( :name=>"templated", :content => "Bar" )
      #@card.should_receive(:setting_card).at_least(:twice).with("content").and_return(config_card)
      result = Slot.new(@card).render(:edit)
      result.should be_html_with do
        div :class => "edit_in_multi" do
          #input :name=>"cards[~plus~alpha][content]", :type => 'hidden' 
        end
      end
    end
  end
  
  describe "diff" do
    it "should not overwrite empty content with current" do
      User.as(:wagbot)
      c = Card.create! :name=>"ChChChanges", :content => ""
      c.update_attributes :content => "A"
      c.update_attributes :content => "B"
      r = Slot.new(c).render_diff( c, c.revisions[0].content, c.revisions[1].content )
      r.should == "<ins class=\"diffins\">A</ins>"
    end
  end
end

