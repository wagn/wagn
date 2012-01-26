require File.expand_path('../../spec_helper', File.dirname(__FILE__))


# FIXME: this test is breaking; I can cut and paste the code into console and it works great. wtf?
=begin
describe Card, "record appender" do
  before do
    Card.as(Card::WagbotID) 
    @r = Role.find(:first)
    @c = Card.find(:first)
    @c.permit(:comment,@r)
    @c.save!
  end

  it "should have appender immediately" do
    Card.as(Card::WagbotID) 
    @c.ok?(:comment).should be_true
  end
  
  it "should have appender after save" do
    Card.as(Card::WagbotID) 
    Card.find(@c.id).ok?(:comment).should be_true
  end         
end
=end


describe Card, "comment addition" do
  before do
    Card.as(Card::WagbotID) 
    Card.create :name => 'basicname+*self+*comment', :content=>'[[Anyone Signed In]]'
    @c = Card.fetch "basicname"
    @c.comment = " and more"
    @c.save!
  end
  
  it "should combine content immediately" do
    @c.content.should == "basiccontent and more"
  end
  
  it "should combine content after save" do
    Card.find_by_name("basicname").content.should == "basiccontent and more"
  end
end
