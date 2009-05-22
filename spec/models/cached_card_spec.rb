require File.dirname(__FILE__) + '/../spec_helper'


describe "CachedCard semi-integration" do
  if CachedCard.perform_caching
    it "should return a cached card the second time" do
      CachedCard.get("A");  # populate the cache if we haven't gotten this card yet
      CachedCard.find("a").should be_instance_of(CachedCard)  # should be in the cache now
    end

    it "should not find a card after bumping the sequence" do
      CachedCard.get("A");  # populate the cache if we haven't gotten this card yet
      CachedCard.bump_global_seq
      CachedCard.find("a").should == nil
    end
  end
end

 

describe "CachedCard" do
  before do
    @mc = flexmock()           
    CachedCard.reset_cache
    CachedCard.cache = @mc    
    @gs_key = System.host + '/test/global_seq'
  end    

  it "bump_global_seq should change global_seq" do
    @mc.should_receive(:read).with(@gs_key)
    @mc.should_receive(:read).with(@gs_key)
    @mc.should_receive(:write)
    initial = CachedCard.global_seq  
    sleep(0.02)  # long enough for time counter to register new value.
    CachedCard.bump_global_seq.to_i.should > initial.to_i
  end
  
  it "global_seq should return value when no global_seq is cached" do
    @mc.should_receive(:read).with(@gs_key).and_return(nil)
    @mc.should_receive(:write)
    CachedCard.global_seq.should_not be_nil
  end
  
  it  "global_seq should return cached value when present" do
    @mc.should_receive(:read).with(@gs_key).and_return("2")
    CachedCard.global_seq.should == 2
  end
  
  after do
    CachedCard.cache = ActionController::Base.cache_store  # restore default for other tests
  end
end


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


  it "should only forward p to the card the first time" do
    mc = flexmock(); mc.should_receive(:name).times(1).and_return("cardname")
    cc = CachedCard.new('a', mc)
    
    cc.name.should == "cardname"
    cc.name.should == "cardname"
  end

end





