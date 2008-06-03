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
  
  it "should render transclusions in view" do
    @a = Card.new(:name=>'weird_t', :content=>"{{A}}")
    @a.send(:set_defaults)
    Slot.new(@a).render(:view).should ==  "<span cardId=\"\" class=\"card-slot paragraph full cardid-\" position=\"1\" >\n<div class=\"view\">\n<span class=\"content editOnDoubleClick\"><span cardId=\"80\" class=\"transcluded cardid-80\" position=\"1\" ><span class=\"content editOnDoubleClick\">Alpha <a class=\"known-card\" href=\"/wagn/Z\">Z</a></span></span></span>\n</div>\n</span>" 
  end    
  
  

end

