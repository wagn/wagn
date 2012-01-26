require File.expand_path('../spec_helper', File.dirname(__FILE__))


describe Role, "Authenticated User" do
  before do
    @auth = Card[Card::AuthID]
  end
  
  it "should cache roles by id" do
    Card[@auth.id]
    Card.should_not_receive(:find)
    Card[@auth.id]
  end
end

=begin
describe User, "Anonymous User" do
  before do
    User.current_user = ::User['anon']
  end
  
  it "should ok anon role" do Wagn.role_ok?(Role['anon'].id).should be_true end
  it "should not ok auth role" do Wagn.role_ok?(Role['auth'].id).should_not be_true end
end

describe User, "Authenticated User" do
  before do
    User.current_user = ::User.where(:card_id=>Card['joe_user'].id).first
  end
  it "should ok anon role" do Wagn.role_ok?(Role['anon'].id).should be_true end
  it "should ok auth role" do Wagn.role_ok?(Role['auth'].id).should be_true end
end
=end

describe User, "Admin User" do
  before do
    User.current_user = ::User[:wagbot]
  end
#  it "should ok admin role" do Wagn.role_ok?(Role['admin'].id).should be_true end
  
  it "should have correct parties" do
    User.current_user.parties.sort.should == [Card::WagbotID, Card::AuthID, Card::AdminID]
  end
    
end

describe User, 'Joe User' do
  before do
    User.current_user = :joe_user
    User.cache.delete 'joe_user'
    @ju = User.current_user
    @jucard = Card['joe_user']
    @r1 = Card['r1']
    @roles_card=@jucard.star_rule(:roles)
  end
  
  it "should initially have no roles" do
    #warn "roles card #{@roles_card.inspect}"
    @roles_card.type_id.should==Card::PointerID

    @roles_card.item_names.length.should==0
  end
  it "should immediately set new roles and return auth, anon, and the new one" do
    User.as(:wagbot) { @roles_card << @r1 }
    @roles_card.item_names.length.should==1
  end
  it "should save new roles and reload correctly" do
    User.as(:wagbot) {
      @roles_card.content=''
      @roles_card << @r1;
    }
    @ju = User.where(:card_id=>Card['joe_user'].id).first
    @roles_card = Card[@jucard.star_rule(:roles).id]
    @roles_card.item_names.length.should==1  
    @ju.parties.should == [Card::AuthID, Card['r1'].id, @ju.card_id]
  end
  
  it "should be 'among' itself" do
    @ju.among?([Card['joe_user'].id]).should == true
    @ju.among?([Card['r1'].id,Card['joe_user'].id,Card['r2'].id]).should == true
  end
  
end
