require File.dirname(__FILE__) + '/../../spec_helper'
    
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
  
end
