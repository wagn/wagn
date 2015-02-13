# -*- encoding : utf-8 -*-

class Card
  cattr_accessor :count

  module Set::Type
  
    module CardtypeA
      extend Card::Set

      def ok_to_delete
        deny_because("not allowed to delete card a")
      end
    end

#    module CardtypeC
#      extend Card::Set
#    end

    module CardtypeD
      def valid?
        errors.add :create_error, "card d always has errors"
        errors.empty?
      end
    end

    module CardtypeE
      def self.included(base) Card.count = 2   end
      def on_type_change()    decrement_count  end
      def decrement_count()   Card.count -= 1  end
    end

    module CardtypeF
      def self.included(base) Card.count = 2   end
      # FIXME: create_extension doesn't exist anymore, need another hook
      def create_extension()  increment_count  end
      def increment_count()   Card.count += 1  end
    end
  end
end

describe Card, "with role" do
  before do
    Card::Auth.as_bot do
      @role = Card.search(:type=>'Role')[0]
    end
  end

  it "should have a role type" do
    expect(@role.type_id).to eq(Card::RoleID)
  end
end



describe Card, "with account" do
  before do
    Card::Auth.as_bot do
      @joe = change_card_to_type('Joe User', :basic)
    end
  end

  it "should not have errors" do
    expect(@joe.errors.empty?).to eq(true)
  end

  it "should allow type changes" do
    expect(@joe.type_code).to eq(:basic)
  end

end

describe Card, "type transition approve create" do
  it 'should have cardtype b create role r1' do
    expect((c=Card.fetch('Cardtype B+*type+*create')).content).to eq('[[r1]]')
    expect(c.type_code).to eq(:pointer)
  end

  it "should have errors" do
    c = change_card_to_type("basicname", "cardtype_b")
    expect(c.errors[:permission_denied]).not_to be_empty
  end

  it "should be the original type" do
    lambda { change_card_to_type("basicname", "cardtype_b") }
    expect(Card["basicname"].type_code).to eq(:basic)
  end
end


#describe Card, "type transition validate_delete" do
#  before do @c = change_card_to_type("type-c-card", :basic) end
#
#  it "should have errors" do
#    @c.errors[:delete_error].first.should == "card c is indestructible"
#  end
#
#  it "should retain original type" do
#    Card["type_c_card"].type_code.should == :cardtype_c
#  end
#end

describe Card, "type transition validate_create" do
  before do @c = change_card_to_type("basicname", "cardtype_d") end

  it "should have errors" do
    pending "CardtypeD does not have a codename, so this is an invalid test"
    expect(@c.errors[:type].first.match(/card d always has errors/)).to be_truthy
  end

  it "should retain original type" do
    pending "CardtypeD does not have a codename, so this is an invalid test"
    expect(Card["basicname"].type_code).to eq(:basic)
  end
end

describe Card, "type transition delete callback" do
  before do
    @c = change_card_to_type("type-e-card", :basic)
  end

  it "should decrement counter in before delete" do
    pending "no trigger for this test anymore"
    expect(Card.count).to eq(1)
  end

  it "should change type of the card" do
    expect(Card["type-e-card"].type_code).to eq(:basic)
  end
end

describe Card, "type transition create callback" do
  before do
    Card::Auth.as_bot do
      Card.create(:name=>'Basic+*type+*delete', :type=>'Pointer', :content=>"[[Anyone Signed in]]")
    end
    @c = change_card_to_type("basicname", :cardtype_f)
  end

  it "should increment counter"  do
    pending "No extensions, so no hooks for this now"
    expect(Card.count).to eq(3)
  end

  it "should change type of card" do
    expect(Card["basicname"].type_code).to eq(:cardtype_f)
  end
end


def change_card_to_type name, type
  card = Card.fetch(name)
  tid=card.type_id = Symbol===type ? Card::Codename[type] : Card.fetch_id(type)
  #warn "card[#{name.inspect}, T:#{type.inspect}] is #{card.inspect}, TID:#{tid}"
  r=card.save
  #warn "saved #{card.inspect} R#{r}"
  card
end



