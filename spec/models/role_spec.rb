require File.expand_path('../spec_helper', File.dirname(__FILE__))


describe Role, "Authenticated User" do
  before do
    @auth = Role[:auth]
  end
  
  it "should cache roles by codename" do
    pending "uses Codename and Card caches now"
    Role.should_not_receive(:find_by_codename)
    Role[:auth]
  end

  it "should cache roles by id" do
    pending "uses Codename and Card caches now"
    Role[@auth.id]
    Role.should_not_receive(:find)
    Role[@auth.id]
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
    User.current_user = ::User.find_by_login('joe_user')
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
    @roles_card = @jucard.star_rule(:roles)
  end
  
  it "should initially have no roles" do
    warn "roles card #{@roles_card.inspect}"
    @roles_card.type_id.should==Card::PointerID

    @roles_card.item_names.length.should==0
  end
  it "should immediately set new roles and return auth, anon, and the new one" do
    @roles_card << @r1
    @roles_card.item_names.length.should==1
  end
  it "should save new roles and reload correctly" do
    @roles_card.content="[[#{@r1.name}]]"
    @ju = User.find_by_login 'joe_user'
    @roles_card = Card.fetch_or_new(@jucard.star_rule(:roles))
    @roles_card.item_names.length.should==1  
    @ju.parties.should == [Card::AuthID, Card['joe_user'].id, Card['r1'].id]
  end
  
  it "should be 'among' itself" do
    @ju.among?([Card['joe_user'].id]).should == true
    @ju.among?([Card['r1'].id,Card['joe_user'].id,Card['r2'].id]).should == true
  end
  
end
