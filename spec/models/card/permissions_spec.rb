require File.dirname(__FILE__) + '/../../spec_helper'



describe Card, "default permissions" do
  before do
    User.as :joe_user do
      @c = Card.create! :name=>"sky blue"
    end
  end
  
  it "should let anonymous users view basic cards" do
    User.as :anon
    @c.ok?(:read).should be_true
  end
  
  it "should let joe view basic cards" do
    User.as :joe_user
    @c.ok?(:read).should be_true
  end
end
       
describe Card, "new permissions" do
  it "should let joe view new cards" do
    @c = Card.new
    @c.send(:set_defaults)
    @c.ok?(:read).should be_true
  end

  it "should let joe render content of new cards" do
    @c = Card.new
    @c.send(:set_defaults)
    Renderer.instance.render(@c).should == ''
  end

end
  
=begin
describe Card, "permissions" do      
  it "should let anonymous users view basic cards" do
    User.as :anon
    Card.find_by_name("Sample Basic").ok?(:read).should be_true
  end
  
  it "should let joe view basic cards" do
    User.as :joe_user
    Card.find_by_name("Sample Basic").ok?(:read).should be_true
  end
end
=end