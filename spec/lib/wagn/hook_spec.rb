require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Wagn::Hook do
  it "module exists and autoloads" do
    Wagn::Hook.should be_true
  end                      

  describe ".ephemerally" do
    it "restores registry to original state after running block" do
      reg = Wagn::Hook.registry.clone
      Wagn::Hook.ephemerally do
        Wagn::Hook.add :save, "Book+*type" do "fish" end
        Wagn::Hook.registry.should_not == reg
      end
      Wagn::Hook.registry.should == reg
    end
  end

  describe ".invoke" do
    before(:all){  Fish = mock("cod") }
    before do
      Wagn::Hook.add :save, "Book+*type" do
        Fish.hooked
      end
    end

    it "invokes hooks on matching cards" do
      Fish.should_receive("hooked").once
      Wagn::Hook.call :save, Card.new(:type => "Book", :name=>"Hitchhikers Guide")    
    end
  
    it "does note invoke hooks on non-matching cards" do
      Fish.should_not_receive("hooked")
      Wagn::Hook.call :save, Card.new(:type => "Basic", :name=>"button")    
    end

    it "invokes hooks for set names" do
      
    end

    it "invokes multiple registered hooks with arguments" do
      Fish.should_receive("hooked").once.with("boo")
      Fish.should_receive("hooked").once.with("more boo")
      Wagn::Hook.add(:samplehook, '*all') do |card, arg|
        Fish.hooked arg
      end
      Wagn::Hook.add(:samplehook, '*all') do |card, arg|
        Fish.hooked "more #{arg}"
      end
      Wagn::Hook.call :samplehook, '*all', "boo"
    end
  end
end


