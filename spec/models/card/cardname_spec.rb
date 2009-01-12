require File.dirname(__FILE__) + '/../../spec_helper'
=begin
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


describe Cardname, "Underscores" do
  it "should be treated like spaces when making keys" do
    'weird_ combo'.to_key.should == 'weird  combo'.to_key
  end
  it "should not impede pluralization checks" do
    'Mamas_and_Papas'.to_key.should == "Mamas and Papas".to_key
  end
end
=end
describe Cardname, "changing from plus card to simple" do
  before do
    User.as :joe_user
    @c = Card.create! :name=>'four+five'
    @c.name = 'nine'
    @c.confirm_rename = true
    @c.save
  end
    
    
  
  it "should erase trunk and tag ids" do
    @c.trunk_id.should== nil
    @c.tag_id.should== nil
  end
end