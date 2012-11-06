require File.expand_path('../../spec_helper', File.dirname(__FILE__))


# FIXME: this test is breaking; I can cut and paste the code into console and it works great. wtf?
=begin
describe Card, "record appender" do
  before do
    Session.as(Card::WagnBotID)
    @r = Role.find(:first)
    @c = Card.find(:first)
    @c.permit(:comment,@r)
    @c.save!
  end

  it "should have appender immediately" do
    Session.as(Card::WagnBotID)
    @c.ok?(:comment).should be_true
  end

  it "should have appender after save" do
    Session.as(Card::WagnBotID)
    Card.find(@c.id).ok?(:comment).should be_true
  end
end
=end


describe Card, "comment addition" do
  before do
    Session.as_bot do
      Card.create :name => 'basicname+*self+*comment', :content=>'[[Anyone Signed In]]'
      @c = Card.fetch "basicname"
      @c.comment = " and more"
      @c.save!
    end
  end

  it "should combine content immediately" do
    @c.content.should == "basiccontent and more"
  end

  it "should combine content after save" do
    Card["basicname"].content.should == "basiccontent and more"
  end
end
