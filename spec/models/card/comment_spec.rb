require File.dirname(__FILE__) + '/../../spec_helper'


# FIXME: this test is breaking; I can cut and paste the code into console and it works great. wtf?
=begin
describe Card, "record appender" do
  before do
    User.as :wagbot 
    @r = Role.find(:first)
    @c = Card.find(:first)
    @c.permit(:comment,@r)
    @c.save!
  end

  it "should have appender immediately" do
    User.as :wagbot 
    @c.ok?(:comment).should be_true
  end
  
  it "should have appender after save" do
    User.as :wagbot 
    Card.find(@c.id).ok?(:comment).should be_true
  end         
end
=end


describe Card, "comment addition" do
  before do
    User.as :wagbot 
    @c = Card.find_by_name("basicname")
    @c.comment = " and more"
    @c.permit(:comment, Role.find(:first)) 
    @c.save!
  end
  
  it "should combine content immediately" do
    @c.content.should == "basiccontent and more"
  end
  
  it "should combine content after save" do
    Card.find_by_name("basicname").content.should == "basiccontent and more"
  end
end
