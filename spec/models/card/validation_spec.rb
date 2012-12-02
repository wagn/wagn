require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Card, "validate name" do
  before(:each) do
    Account.as :joe_user
  end

  it "should error on name with /" do
    @c = Card.create :name=>"testname/"
    @c.errors[:name].should_not be_blank
  end

  it "should error on junction name  with /" do
    @c = Card.create :name=>"jasmin+ri/ce"
    @c.errors[:name].should_not be_blank
  end

  it "shouldn't create any new cards when name invalid" do
    original_card_count = Card.count
    @c = Card.create :name=>"jasmin+ri/ce"
    Card.count.should == original_card_count
  end

  it "should not allow empty name" do
    @c = Card.new :name=>""
    @c.valid?.should == false
    @c.errors[:name].should_not be_blank
  end

  # maybe the @c.key= should just throw an error, but now it doesn't take anyway
  it "should not allow mismatched name and key" do
    @c = Card.new :name=>"Test"
    @c.key="foo"
    #@c.key.should == 'test'
    @c.valid?.should == false
    #@c.errors[:key].should_not be_blank
  end

end
