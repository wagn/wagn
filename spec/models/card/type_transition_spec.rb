require File.expand_path('../../spec_helper', File.dirname(__FILE__))

class Card
  cattr_accessor :count
end

module Wagn::Set::Type::CardtypeA 
  def approve_delete 
    deny_because("not allowed to delete card a")
  end
end

  
module Wagn::Set::Type::CardtypeC
  def validate_type_change
    errors.add :destroy_error, "card c is indestructible"
  end
end

module Wagn::Set::Type::CardtypeD
  def valid?
    errors.add :create_error, "card d always has errors"
    errors.empty?
  end
end

module Wagn::Set::Type::CardtypeE
  def self.included(base) Card.count = 2   end
  def on_type_change()    decrement_count  end
  def decrement_count()   Card.count -= 1  end
end

module Wagn::Set::Type::CardtypeF
  def self.included(base) Card.count = 2   end
  def create_extension()  increment_count  end
  def increment_count()   Card.count += 1  end
end


describe Card, "with role" do
  before do
    Card.as(Card::WagbotID) 
    @role = Card.search(:type=>'Role')[0]
  end
  
  it "should have a role type" do
    @role.type_id.should== Card::RoleID
  end
end



describe Card, "with account" do
  before do
    Card.as(Card::WagbotID) 
    @joe = change_card_to_type('Joe User', 'Basic')
  end
  
  it "should not have errors" do
    @joe.errors.empty?.should == true
  end

  it "should allow type changes" do
    @joe.typecode.should == 'Basic'
  end

end

describe Card, "type transition approve create" do
  before do
    Card.as(Card::WagbotID) do
      # this card/content is in the test DB, and this causes a duplicate id error
      #Card.create :name=>'Cardtype B+*type+*create', :content=>'[[r1]]'
      (c=Card.fetch('Cardtype B+*type+*create')).content.should == '[[r1]]'
      c.typecode.should == 'Pointer'
    end
  end
  
  it "should have errors" do
      Rails.logger.info "testing point 2"
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
    @c.errors[:destroy_error].first.should == "card c is indestructible"
  end
  
  it "should retain original type" do
    Card.find_by_name("type_c_card").typecode.should == 'CardtypeC'
  end
end

describe Card, "type transition validate_create" do
  before do @c = change_card_to_type("basicname", "CardtypeD") end
  
  it "should have errors" do
    @c.errors[:type].first.match(/card d always has errors/).should be_true
  end
  
  it "should retain original type" do
    Card.find_by_name("basicname").typecode.should == 'Basic'
  end
end

describe Card, "type transition destroy callback" do
  before do
    @c = change_card_to_type("type-e-card", "Basic") 
  end
  
  it "should decrement counter in before destroy" do
    Card.count.should == 1
  end
  
  it "should change type of the card" do
    Card.find_by_name("type-e-card").typecode.should == 'Basic'
  end
end

describe Card, "type transition create callback" do
  before do 
    Card.as(Card::WagbotID) do
      Card.create(:name=>'Basic+*type+*delete', :type=>'Pointer', :content=>"[[Anyone Signed in]]")
    end
    @c = change_card_to_type("basicname", 'CardtypeF') 
  end
    
  it "should increment counter"  do
    Card.count.should == 3
  end
  
  it "should change type of card" do
    Card.find_by_name("basicname").typecode.should == 'CardtypeF'
  end
end                


def change_card_to_type(name, typecode)
  Card.as :joe_user do
    card = Card.fetch(name)
   #warn "card[#{name}] is #{card.inspect}, #{Card.type_id_from_code(typecode)}"
    card.type_id = Card.type_id_from_code typecode
    card.save
    card
  end
end



