require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe "if_card" do
  it "should run block for existing card" do
    if_card("A") {|c| c.name}.should == "A"
  end

  it "should not run block for missing card" do
    if_card("zgth") {|c| raise("oops")}.should == nil
  end
end

describe "else" do
  it "returns object for non-nil objects" do
    "this".else("that").should == "this"
  end

  it "returns default for nil objects" do
    nil.else("that").should == "that"
  end
end

