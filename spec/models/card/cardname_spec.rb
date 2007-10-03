require File.dirname(__FILE__) + '/../../spec_helper'

describe Cardname, "to_key" do
  it "should remove spaces" do
    "This Name".to_key.should == "this_name"
  end
end

describe Card, "Case Variant" do
  before do
    User.as :joe_user
    @c = Card.create! :name=>'chump'
  end
  it "should be able to change to a capitalization" do
    @c.name = 'Chump'
    @c.save!
    @c.name.should == 'Chump'
  end
end