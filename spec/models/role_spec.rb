require File.expand_path('../spec_helper', File.dirname(__FILE__))

#FIXME: all this belongs someplace else (or delete it)

describe Card, "Authenticated User" do
  before do
    @auth = Card[Card::AuthID]
  end

  it "should cache roles by id" do
    Card[@auth.id]
    mock.dont_allow(Card).find
    Card[@auth.id]
  end
end

=begin
describe User, "Anonymous User" do
  before do
    Session.user= Card::AnonID
  end

  it "should ok anon role" do Wagn.role_ok?(Role['anon'].id).should be_true end
  it "should not ok auth role" do Wagn.role_ok?(Role['auth'].id).should_not be_true end
end

describe User, "Authenticated User" do
  before do
    Session.user= 'joe_user'
  end
  it "should ok anon role" do Wagn.role_ok?(Role['anon'].id).should be_true end
  it "should ok auth role" do Wagn.role_ok?(Role['auth'].id).should be_true end
end
=end

describe User, "Admin User" do
  before do
    Session.user= Card::WagnBotID
  end
#  it "should ok admin role" do Wagn.role_ok?(Role['admin'].id).should be_true end

  it "should have correct parties" do
    Session.user_card.parties.sort.should == [Card::WagnBotID, Card::AuthID, Card::AdminID]
  end

end

describe User, 'Joe User' do
  before do
    Session.user= :joe_user
    User.cache.delete 'joe_user'
    @ju = Session.user
    @jucard = Session.user_card
    @r1 = Card['r1']
    @roles_card=@jucard.fetch(:new=>{},:trait=>:roles)
  end

  it "should initially have no roles" do
    #warn "roles card #{@roles_card.inspect}"
    @roles_card.type_id.should==Card::PointerID

    @roles_card.item_names.length.should==0
  end
  it "should immediately set new roles and return auth, anon, and the new one" do
    Session.as_bot { @roles_card << @r1 }
    @roles_card.item_names.length.should==1
  end
  it "should save new roles and reload correctly" do
    Session.as_bot {
      @roles_card.content=''
      @roles_card << @r1;
    }
    @ju = Card['joe_user'].to_user
    @roles_card = Card[@jucard.fetch(:new=>{},:trait=>:roles).id]
    @roles_card.item_names.length.should==1
    @jucard.parties.should == [Card::AuthID, Card['r1'].id, @ju.card_id]
  end

  it "should be 'among' itself" do
    @jucard.among?([Card['joe_user'].id]).should == true
    @jucard.among?([Card['r1'].id,Card['joe_user'].id,Card['r2'].id]).should == true
  end

end
