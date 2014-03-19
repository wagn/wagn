# -*- encoding : utf-8 -*-


# FIXME: this test is breaking; I can cut and paste the code into console and it works great. wtf?
describe Card, "record appender" do
  before do
    @r = Card.where(:type_id=>Card::RoleID).first
    @rule = Card.new :name=>'A+*self+*comment', :type_id=>Card::PointerID, :content=>"[[#{@r.name}]]"
  end

  it "should have appender immediately" do
    Card['a'].ok?(:comment).should_not be_true
    Card::Auth.as_bot do
      @rule.save!
    end
    Card['a'].ok?(:comment).should be_true
  end

  it "should have appender immediately" do
    Card::Auth.as(Card::WagnBotID) do Card['a'].ok?(:comment).should_not be_true end
    Card::Auth.as_bot do @rule.save! end
    Card::Auth.as(Card::WagnBotID) do Card['a'].ok?(:comment).should be_true end
  end
end


describe Card, "comment addition" do
  it "should combine content after save" do
    Card::Auth.as_bot do
      Card.create :name => 'basicname+*self+*comment', :content=>'[[Anyone Signed In]]'
      @c = Card.fetch "basicname"
      @c.comment = " and more\n  \nsome lines\n\n"
      @c.save!
    end
    Card["basicname"].content.should =~ /\<p\>some lines\<\/p\>/
  end
end
