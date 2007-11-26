require File.dirname(__FILE__) + '/../spec_helper'
 
=begin 
describe Card, "updates" do
  before do
    User.as :joe_user
    @a = Card["A"]
  end

  it "should clear name updates after successful save" do
    @a.name = "Alpha"; @a.confirm_rename = true
    @a.save!   
    @a.updates.for?(:name).should==false
  end

  it "should clear content updates after successful save" do
    @a.content = "balogna"
    @a.save!   
    @a.updates.for?(:content).should==false
  end
end


describe Card, "changed?" do              
  before do
    User.as :joe_user
    @a = Card["A"]
  end

  it "should return false before save" do
    @a.content = "balogna"
    @a.changed?(:content).should==false
  end

  it "should return false if save fails due to validation" do
    @a.content = "balogna"
    @a.name = "B" # err- already exists
    @a.save.should == false  # verify save fails 
    @a.changed?(:content).should==false
  end
                                                                    
  # How do we know that save succeeds?
  it "should return true for changed field (only) if save succeeds" do
    @a.content = "balogna"
    @a.save!
    @a.changed?(:name).should == false
    @a.changed?(:content).should == true
  end
  
  it "should reset when field is updated again" do
    @a.content = "balogna";    @a.save!
    @a.content = "boogey"
    @a.changed?(:content).should == false
  end
  
end

describe CachedCard, "flexmock test" do
  it "should be able to create a mock" do
    m = flexmock()
    m.should_receive(:content).times(1).and_return(:blug)
    m.content
  end                     
end
=end        

describe CachedCard, "access" do
  before do 
    CachedCard.new('a').expire_all
  end
  
  it "should save and retrieve content" do
    cc = CachedCard.new('a')
    cc.write(:content, "foo")
    cc.read(:content).should=="foo"
  end

  it "should only forward name to the card the first time" do
    mc = flexmock()
    mc.should_receive(:name).times(1).and_return("cardname")
    
    cc = CachedCard.new('a', mc)
    cc.name.should == "cardname"
    cc.name.should == "cardname"
  end
  
  it "should only forward id to the card" do
    mc = flexmock()
    mc.should_receive(:id).times(1).and_return(32)
    
    cc = CachedCard.new('a', mc)
    cc.id.should == 32
    cc.id.should == 32
  end


  it "should save and retrieve line_content" do
    cc = CachedCard.new('a')
    cc.line_content = "woot"
    cc.line_content.should=="woot"
  end

  it "should save and retrieve view_content" do
    cc = CachedCard.new('a')
    cc.view_content = "woot"
    cc.view_content.should=="woot"
  end
  
  it "should not have content after expiration" do
    cc = CachedCard.new('a')
    cc.view_content = "woot"
    cc.expire_all
    cc.view_content.should==nil
  end


=begin
  it "should only forward p to the card the first time" do
    mc = flexmock(); mc.should_receive(:name).times(1).and_return("cardname")
    cc = CachedCard.new('a', mc)
    
    cc.name.should == "cardname"
    cc.name.should == "cardname"
  end
=end

end





