require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Card, "normal user create permissions" do
  before do
    Session.as :joe_user
  end
  it "should allow anyone signed in to create Basic Cards" do
    Card.new(:type=>'Basic').ok?(:create).should be_true
  end
end

describe Card, "anonymous create permissions" do
  before do
    Session.as :anonymous
  end
  it "should not allow someone not signed in to create Basic Cards" do
    c = Card.new(:type=>'Basic')
    c.ok?(:create).should_not be_true
  end
end
        

