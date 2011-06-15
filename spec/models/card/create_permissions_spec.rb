require File.dirname(__FILE__) + '/../../spec_helper'

describe Card, "normal user create permissions" do
  before do
    User.as :joe_user
  end
  it "should allow anyone signed in to create Basic Cards" do
    Card::Basic.create_ok?.should be_true
    Card.new(:type=>'Basic').ok?(:create).should be_true
  end
end

describe Card, "anonymous create permissions" do
  before do
    User.as :anon
  end
  it "should not allow someone not signed in to create Basic Cards" do
    Card::Basic.create_ok?.should_not be_true
    Card.new(:type=>'Basic').ok?(:create).should_not be_true
  end
end
        

