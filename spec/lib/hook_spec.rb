require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Hook do
  it "module exists and autoloads" do
    Hook.should be_true
  end                      
end

describe SystemHook do
  before(:each) do       
    SystemHook.reset
    Fish = mock("fish")    
  end                  
  
  it "invokes multiple registered hooks with arguments" do
    Fish.should_receive("hooked").once.with("boo")
    Fish.should_receive("hooked").once.with("more boo")
    SystemHook.register :samplehook do |arg|
      Fish.hooked arg
    end
    SystemHook.register :samplehook do |arg|
      Fish.hooked "more #{arg}"
    end
    SystemHook.invoke :samplehook, "boo"
  end
end                                 

describe CardHook do
  before(:each) do    
    CardHook.reset
    CardHook.register :save, { :type => "Book" } do
      Fish.hooked
    end
  end
  
  it "invokes hooks on matching cards" do
    Fish.should_receive("hooked").once
    CardHook.invoke :save, Card.new(:type => "Book", :name=>"Hitchhikers Guide")    
  end
  
  it "does note invoke hooks on non-matching cards" do
    Fish.should_not_receive("hooked")
    CardHook.invoke :save, Card.new(:type => "Basic", :name=>"button")    
  end
end
