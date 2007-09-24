require File.dirname(__FILE__) + '/../../spec_helper'


describe Card, "Recreated Card" do
  before do
    User.as :admin
    @ct = Card::Cardtype.create! :name=>'Species'
    @ct.destroy!
    @ct = Card::Cardtype.create! :name=>'Species'
  end
  
  it "should have a cardtype extension" do
    @ct.extension.should_not be_nil
  end
  
end


describe Card, "Normal card with junctions" do
  before do
    User.as :admin
    @a = Card['a']
  end
  it "should confirm that it has junctions" do
    @a.junctions.length.should > 0
  end
  it "should successfull have its type changed" do
    @a.type = 'CardtypeE'; @a.save!
    Card['a'].type.should== 'CardtypeE'
  end
  it "should still have its junctions after changing type" do
    @a.type = 'CardtypeE'; @a.save!
    Card['a'].junctions.length.should > 0
  end
end


describe Card, "New Cardtype" do
  before do
    User.as :admin
    @ct = Card::Cardtype.create! :name=>'Animal'
  end
  
  it "should have create permissions" do
    @ct.who_can(:create).should_not be_nil
  end
  it "its create permissions should be based on Basic" do
    @ct.who_can(:create).should == Card['Basic'].who_can(:create)
  end
end




describe Card, "Wannabe Cardtype Card" do
  before do
    User.as :admin
    @card = Card.create! :name=> 'convertible'
    @card.type='Cardtype'
    @card.save!
    
  end
  it "should successfully change its type to a Cardtype" do
    Card['convertible'].type.should=='Cardtype'
  end
  it "should have an extension" do
    Card['convertible'].extension.should_not== nil
  end
end



describe User, "Joe User" do
  before do
    User.as :admin
    @r3 = Role[:r3]
    @ctf_t = Card.create! :name=>'Cardtype F+*template'
    @ctf_t.permit(:create, @r3)
    @ctf_t.save!

    User.as :joe_user
    @user = User[:joe_user]
    @ctf = Card['Cardtype F']
    @cardtype_names = @user.createable_cardtypes.map{ |ct| ct[:name] }
  end

  it "should not have r3 permissions" do
    @user.roles.member?(@r3).should_not be_true
  end
  it "should ponder creating a card of Cardtype F, but find that he lacks create permissions" do
    @ctf.ok?(:create).should_not be_true
  end
  it "should not find Cardtype F on its list of createable cardtypes" do
    @cardtype_names.member?('Cardtype F').should_not be_true
  end
  it "should find Basic on its list of createable cardtypes" do
    @cardtype_names.member?('Basic').should be_true
  end
  
end

=begin  
(These are actually busted)

describe Card, "Cardtype with Existing Cards" do
  before do
    User.as :admin
    @ct = Card['Basic']
  end
  it "should have existing cards of that type" do
    @ct.me_type.find(:all).should_not be_empty
  end
  ##FIXME -- this doesn't work yet
  it "should raise an error when you try to delete it" do
    @ct.destroy
    @ct.errors.on(:type).should_not be_empty
  end
end

=end
