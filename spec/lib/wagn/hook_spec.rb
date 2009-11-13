require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Wagn::Hook do
  it "module exists and autoloads" do
    Wagn::Hook.should be_true
  end                      
end

describe Wagn::Hook::System do
  before(:each) do       
    Wagn::Hook::System.reset
    Fish = mock("fish")    
  end                  
  
  it "invokes multiple registered hooks with arguments" do
    Fish.should_receive("hooked").once.with("boo")
    Fish.should_receive("hooked").once.with("more boo")
    Wagn::Hook::System.register :samplehook do |arg|
      Fish.hooked arg
    end
    Wagn::Hook::System.register :samplehook do |arg|
      Fish.hooked "more #{arg}"
    end
    Wagn::Hook::System.invoke :samplehook, "boo"
  end
end                                 

describe Wagn::Hook::Card do
  before(:each) do
    Cod = mock("cod")
    Wagn::Hook::Card.reset
    Wagn::Hook::Card.register :save, { :type => "Book" } do
      Cod.hooked
    end
  end
  
  it "invokes hooks on matching cards" do
    Cod.should_receive("hooked").once
    Wagn::Hook::Card.invoke :save, Card.new(:type => "Book", :name=>"Hitchhikers Guide")    
  end
  
  it "does note invoke hooks on non-matching cards" do
    Cod.should_not_receive("hooked")
    Wagn::Hook::Card.invoke :save, Card.new(:type => "Basic", :name=>"button")    
  end
end
