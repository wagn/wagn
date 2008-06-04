require File.dirname(__FILE__) + '/../spec_helper'
Slot=WagnHelper::Slot    

describe WagnHelper::Slot, "" do      
  before { 
    User.as :joe_user 
  }

  it "should render content" do 
    @a = Card.new(:name=>'t', :content=>"[[A]]")
    @a.send(:set_defaults)
    Slot.new(@a).render(:raw).should == "<a class=\"known-card\" href=\"/wagn/A\">A</a>"
  end 

  it "should not render transclusions in raw content" do
     @a = Card.new(:name=>'t', :content=>"{{A}}")
     @a.send(:set_defaults)
    Slot.new(@a).render(:raw_content).should == "{{A}}"
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

