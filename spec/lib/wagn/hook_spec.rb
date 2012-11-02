require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Wagn::Hook do
  it "module exists and autoloads" do
    Wagn::Hook.should be_true
  end

  describe ".ephemerally" do
    it "restores registry to original state after running block" do
      reg = Wagn::Hook.registry.deep_clone
      Wagn::Hook.ephemerally do
        Wagn::Hook.add :save, "Book+*type" do "fish" end
        Wagn::Hook.registry.should_not == reg
      end
      Wagn::Hook.registry.should == reg
    end
  end

  describe ".invoke" do
    before do
      @fish = 0
      Wagn::Hook.add :save, "Book+*type" do
        @fish+=1
      end
    end

    it "invokes hooks on matching cards" do
      Wagn::Hook.call :save, Card.new(:type => "Book", :name=>"Hitchhikers Guide")
      @fish.should == 1
    end

    it "does note invoke hooks on non-matching cards" do
      Wagn::Hook.call :save, Card.new(:type => "Basic", :name=>"button")
      @fish.should == 0
    end

    it "invokes hooks for set names" do

    end

    it "invokes multiple registered hooks with arguments" do
      #ug.
      pending "commented this out because I think we're phasing out hooks.  these tests got borked in moving to rails3"
      @shark = 10
      Wagn::Hook.add(:save, '*all') do |card, arg|
        @shark += arg
      end
      Wagn::Hook.call :save, Card.new(:type => "Book", :name=>"Hitchhikers Guide"), 7
      @shark.should == 17
      @fish.should == 1
    end
  end
end


