require File.dirname(__FILE__) + '/../../spec_helper'

module Card::CardtypeA 
  def approve_delete 
    deny_because("not allowed to delete card a")
  end
end

#  class CardtypeB < Basic                              
    # create restricted in test_data
#  end
  
module Card::CardtypeC
  def self.validate_typecode_change
    errors.add :destroy_error, "card c is indestructible"
  end
end

module Card::CardtypeD
  def self.valid?
    errors.add :create_error, "card d always has errors"
  end
end

module Card::CardtypeE
#  cattr_accessor :count
  @@count = 2
  def on_type_change
    decrement_count
  end
  def decrement_count() @@count -= 1; end
end

module Card::CardtypeF
#  cattr_accessor :count
  @@count = 2
  def before_validation_on_create 
    increment_count
  end
  def increment_count() @@count += 1; end
end


describe Card, "with role" do
  before do
    User.as :wagbot 
    @role = Card.search(:type=>'Role')[0]
  end
  
  it "should have a role extension" do
    @role.extension_type.should=='Role'
  end

  it "should lose role extension upon changing type" do
    # this test fails on a permission error in Mysql
    pending
    @role.typecode = 'Basic'
    @role.save
    @role.extension.should == nil
  end
end



describe Card, "with account" do
  before do
    User.as :wagbot 
    @joe = change_card_to_type('Joe User', 'Basic')
  end
  
  it "should not have errors" do
    @joe.errors.empty?.should == true
  end

  it "should allow type changes" do
    @joe.typecode.should == 'Basic'
  end

  it "should not lose account on card change" do
    @joe.extension.should_not == nil
  end
end



describe Card, "type transition approve create" do
  before do
    Card.create :name=>'Cardtype B+*type+*create', :type=>'Pointer', :content=>'[[r1]]'
  end
  
  it "should have errors" do
    lambda { change_card_to_type("basicname", "CardtypeB") }.should raise_error(Wagn::PermissionDenied)
  end

  it "should be the original type" do
    lambda { change_card_to_type("basicname", "CardtypeB") }
    Card.find_by_name("basicname").typecode.should == 'Basic'
  end
end


describe Card, "type transition validate_destroy" do  
  before do @c = change_card_to_type("type-c-card", 'Basic') end
  
  it "should have errors" do
    @c.errors.on(:destroy_error).should == "card c is indestructible"
  end
  
  it "should retain original type" do
    Card.find_by_name("type_c_card").typecode.should == 'CardtypeC'
  end
end

describe Card, "type transition validate_create" do
  before do @c = change_card_to_type("basicname", "CardtypeD") end
  
  it "should have errors" do
    @c.errors.on(:create_error).should == "card d always has errors"
  end
  
  it "should retain original type" do
    Card.find_by_name("basicname").typecode.should == 'Basic'
  end
end

describe Card, "type transition destroy callback" do
  before do
    Card.search(:return=>'count', :type=>'CardtypeE').should == 2
    @c = change_card_to_type("type-e-card", "Basic") 
  end
  
  it "should decrement counter in before destroy" do
    Card.search(:return=>'count', :type=>'CardtypeE').should == 1
  end
  
  it "should change type of the card" do
    Card.find_by_name("type-e-card").typecode.should == 'Basic'
  end
end

describe Card, "type transition create callback" do
  before do 
    Card.create(:name=>'Basic+*type+*delete', :type=>'Pointer', :content=>"[[Anyone Signed in]]")
    Card.search(:return=>'count', :type=>'CardtypeF').should == 1
    @c = change_card_to_type("basicname", 'CardtypeF') 
  end
    
  it "should increment counter"  do
    Card.search(:return=>'count', :type=>'CardtypeF').should == 2
  end
  
  it "should change type of card" do
    Card.find_by_name("basicname").typecode.should == 'CardtypeF'
  end
end                


def change_card_to_type(name, typecode)
  User.as :joe_user do
    card = Card.fetch(name)
    card.typecode = typecode;
    card.save
    card
  end
end



