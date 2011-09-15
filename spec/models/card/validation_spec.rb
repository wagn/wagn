require_relative '../../spec_helper'
    
describe Card, "validate name" do
  before(:each) do
    ::User.as :joe_user
  end
  
  it "should error on name with /" do
    @c = Card.create :name=>"testname/"
    @c.errors.on(:name).should_not be_blank
  end

  it "should error on junction name  with /" do
    @c = Card.create :name=>"jasmin+ri/ce"
    @c.errors.on(:name).should_not be_blank
  end
  
  it "shouldn't create any new cards when name invalid" do
    original_card_count = Card.count
    @c = Card.create :name=>"jasmin+ri/ce"
    Card.count.should == original_card_count
  end
       
  it "should not allow empty name" do
    @c = Card.new :name=>""
    @c.valid?.should == false
    @c.errors.on(:name).should_not be_blank
  end
  
  it "should not allow mismatched name and key" do
    @c = Card.new :name=>"Test"
    @c.key="foo"  
    @c.valid?.should == false
    @c.errors.on(:key).should_not be_blank
  end

end
