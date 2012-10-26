require File.expand_path('../../spec_helper', File.dirname(__FILE__))
=begin
describe Card, "Case Variant" do
  before do
    Session.as :joe_user
    @c = Card.create! :name=>'chump'
  end             
  
  it "should be able to change to a capitalization" do
    @c.name = 'Chump'
    @c.save!
    @c.name.should == 'Chump'
  end
end


describe NameLogic, "Underscores" do
  it "should be treated like spaces when making keys" do
    'weird_ combo'.to_name.key.should == 'weird  combo'.to_name.key
  end
  it "should not impede pluralization checks" do
    'Mamas_and_Papas'.to_name.key.should == "Mamas and Papas".to_name.key
  end
end
=end
describe NameLogic, "changing from plus card to simple" do
  before do
    Session.as :joe_user
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
