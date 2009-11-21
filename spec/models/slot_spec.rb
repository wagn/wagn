require File.dirname(__FILE__) + '/../spec_helper'
Slot=Slot    

describe Slot, "" do      
  before { 
    User.as :joe_user 
  }

  it "should render content" do 
    @a = Card.new(:name=>'t', :content=>"[[A]]")
    Slot.new(@a).render(:raw).should == "<a class=\"known-card\" href=\"/wagn/A\">A</a>"
  end 

  it "should not render transclusions in raw content" do
     @a = Card.new(:name=>'t', :content=>"{{A}}")
    Slot.new(@a).render(:naked_content).should == "{{A}}"
  end                                                                                  
  
  it "should use transclusion view overrides" do  
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


=begin
  # FIXME: this test is very brittle-- based on specific html;
  #  want to test rendering transclusions, but attributes in the wrapper are built from 
  #  a hash so the order is unpredictable. 
  
  it "should render transclusions in view" do
    @a = Card.new(:name=>'weird_t', :content=>"{{A}}")
    @a.send(:set_defaults)
    Slot.new(@a).render(:view).should ==  "<span  class=\"card-slot paragraph full wrapper cardid- type-Basic\"  position=\"1\"  >\n<div class=\"view\">\n<span class=\"content editOnDoubleClick\"><span  view=\"content\"  class=\"transcluded wrapper cardid-82 type-Basic\"  position=\"1\"  style=\"\"  base=\"self\"  cardId=\"82\"  ><span class=\"content editOnDoubleClick\">Alpha <a class=\"known-card\" href=\"/wagn/Z\">Z</a></span></span></span>\n</div>\n</span>"
      #"<span  class=\"card-slot paragraph full wrapper cardid- type-Basic\"  position=\"1\"  >\n<div class=\"view\">\n<span class=\"content editOnDoubleClick\"><span  base=\"self\"  cardId=\"82\"  class=\"transcluded wrapper cardid-82 type-Basic\"  style=\"\"  position=\"1\"  view=\"content\"  ><span class=\"content editOnDoubleClick\">Alpha <a class=\"known-card\" href=\"/wagn/Z\">Z</a></span></span></span>\n</div>\n</span>"

  end    
=end    
  

end

