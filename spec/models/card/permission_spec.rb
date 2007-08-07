require File.dirname(__FILE__) + '/../../spec_helper'


describe Card, "should record appender" do
  before do
    User.as :admin
    @r = Role.find(:first)
    @c = Card.find(:first)
    @c.appender = @r
    @c.save!
  end

  it "should have appender immediately" do
    @c.appender.should == @r
  end
  
  it "should have appender after save" do
    Card.find(@c.id).appender.should == @r
  end
  
end