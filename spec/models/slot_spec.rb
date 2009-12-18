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
    
    describe "views" do
      it "open" do
        mu = mock(:mu)
        mu.should_receive(:generate).twice.and_return("1")
        UUID.should_receive(:new).twice.and_return(mu)
        Slot.render_content("{{A|open}}").should be_html_with do
          div( :position => 1, :class => "card-slot") {
            div( :class => "card-header" )
            span( :class => "content")  {
              p "Alpha"
            }
          }
        end
      end
    end
    
    it "raw content" do
       @a = Card.new(:name=>'t', :content=>"{{A}}")
      Slot.new(@a).render(:naked_content).should == "{{A}}"
    end                                                                                      
  end

  it "should use inclusion view overrides" do  
    # FIXME love to have these in a scenario so they don't load every time.
    t = Card.create! :name=>'t1', :content=>"{{t2|card}}"
    Card.create! :name => "t2", :content => "{{t3|view}}" 
    Card.create! :name => "t3", :content => "boo" 
    
    # a little weird that we need :expanded_view_content  to get the version without
    # slot divs wrapped around it.
    result = Slot.new(t, "main_1", "view", nil, :inclusion_view_overrides=>{ :open => :name } ).render :expanded_view_content
    result.should == "t2"
    result = Slot.new(t, "main_1", "view", nil, :inclusion_view_overrides=>{ :open => :expanded_view_content } ).render :expanded_view_content
    result.should == "boo"
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
    it "should use content settings" do
      @card = Card.new( :name=>"templated", :content => "bar" )
      @card.should_receive(:setting).with("content").and_return("Yoruba")
      Slot.new(@card).render(:naked_content).should == "Yoruba"
    end
  end
end

