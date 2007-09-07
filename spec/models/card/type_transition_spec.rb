require File.dirname(__FILE__) + '/../../spec_helper'

module Card  
  class CardtypeA < Base  
    def approve_delete 
      deny_because("not allowed to delete card a")
    end
  end

  class CardtypeB < Base                              
    def approve_create
      deny_because "not allowed to create card b"
      deny_because "you stink"
    end
  end
  
  class CardtypeC < Base
    def validate_destroy
      errors.add :destroy, "card c is indestructible"
    end
  end
  
  class CardtypeD < Base 
    def valid?
      errors.add :create, "card d always has errors"
    end
  end
  
  class CardtypeE < Base           
    cattr_accessor :count
    @@count = 2
    before_destroy :decrement_count
    def decrement_count() self.class.count -= 1; end
  end
  
  class CardtypeF < Base
    cattr_accessor :count
    @@count = 2
    before_create :increment_count
    def increment_count() self.class.count += 1; end
  end

end
                                   
describe Card, "clone to type"  do
  before do
    User.as :admin
    @a = Card.find_by_name("basicname")
    @b = @a.send(:clone_to_type, "CardtypeA") 
  end  
  
  it "should have the new type" do
    @b.type.should == 'CardtypeA'
    @b.class.should == Card::CardtypeA
  end
  
  it "should have the same id" do
    @b.id.should == @a.id
  end 
  
  it "should not be a new record" do
    @b.new_record?.should == false
  end
end
                
describe Card, "type transition approve destroy" do
  it "should have errors" do
    lambda { change_card_to_type("type-a-card", "Basic") }.should raise_error(Wagn::PermissionDenied)
  end
              
  it "should still be the original type" do
    lambda { change_card_to_type("type-a-card", "Basic") }
    Card.find_by_name("type-a-card").type.should == 'CardtypeA'
  end
end


describe Card, "type transition approve create" do
  it "should have errors" do
    lambda { change_card_to_type("basicname", "CardtypeB") }.should raise_error(Wagn::PermissionDenied)
  end     

  it "should be the original type" do
    lambda { change_card_to_type("basicname", "CardtypeB") }
    Card.find_by_name("basicname").type.should == 'Basic'
  end
end


describe Card, "type transition validate_destroy" do  
  before do @c = change_card_to_type("type-c-card", 'Basic') end
  
  it "should have errors" do
    @c.errors.on(:destroy).should == "card c is indestructible"
  end
  
  it "should retain original type" do
    Card.find_by_name("type_c_card").type.should == 'CardtypeC'
  end
end



describe Card, "type transition validate_create" do
  before do @c = change_card_to_type("basicname", "CardtypeD") end
  
  it "should have errors" do
    @c.errors.on(:create).should == "card d always has errors"
  end
  
  it "should retain original type" do
    Card.find_by_name("basicname").type.should == 'Basic'
  end
end



describe Card, "type transition destroy callback" do
  before do
    Card::CardtypeE.count = 2
    @c = change_card_to_type("type-e-card", "Basic") 
  end
  
  it "should decrement counter in before destroy" do
    Card::CardtypeE.count.should == 1
  end
  
  it "should change type of the card" do
    Card.find_by_name("type-e-card").type.should == 'Basic'
  end
end

describe Card, "type transition create callback" do
  before do 
    Card::CardtypeF.count = 2
    @c = change_card_to_type("basicname", 'CardtypeF') 
  end
    
  it "should increment counter"  do
    Card::CardtypeF.count.should == 3
  end
  
  it "should change type of card" do
    Card.find_by_name("basicname").type.should == 'CardtypeF'
  end
end                


def change_card_to_type(name, type)
  User.as :admin
  card = Card.find_by_name(name)
  card.type = type;  card.save
  # FIXME FIXME FIXME:  this doesn't work!  something about inheritance column?
  # card.update_attributes :type=>type
  card
end


