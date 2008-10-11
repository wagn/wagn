require File.dirname(__FILE__) + '/../spec_helper'
 

describe "CachedCard" do
  before do
    @mc = flexmock()
    CachedCard.cache = @mc
  end    
  
  it "global_seq should return 1 when no global_seq is cached" do
    @mc.should_receive(:read).with('test/global_seq').and_return(nil)
    @mc.should_receive(:write).with('test/global_seq', 1).and_return(1)
    CachedCard.global_seq.should == 1
  end
  
  it  "global_seq should return cached value when present" do
    @mc.should_receive(:read).with('test/global_seq').and_return("2")
    CachedCard.global_seq.should == 2
  end
  
  it "bump_global_seq should incrememt global_seq" do
    @mc.should_receive(:read).with('test/global_seq').and_return(3)
    @mc.should_receive(:write).with('test/global_seq', 4).and_return(4)
    CachedCard.bump_global_seq.should == 4
  end
  
  after do
    CachedCard.cache = ActionController::Base.fragment_cache_store  # restore default for other tests
  end
end


=begin


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






