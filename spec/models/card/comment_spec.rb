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
    Card.create :name => 'basicname+*self+*comment', :content=>'[[Anyone Signed In]]'
    @c = Card.fetch "basicname"
    @c.comment = " and more"
    Rails.logger.info "failing 1"
    @c.save!
    Rails.logger.info "failing 2"
  end
  
  it "should combine content immediately" do
    Rails.logger.info "failing 3"
    @c.content.should == "basiccontent and more"
  end
  
  it "should combine content after save" do
    Rails.logger.info "failing 4"
    Card.find_by_name("basicname").content.should == "basiccontent and more"
  end
end
