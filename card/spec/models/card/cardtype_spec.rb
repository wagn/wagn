# -*- encoding : utf-8 -*-

class Card
  # REVIEW: hooks api will do this differently, probably should remove and add new tests elsewhere
  # this is used by some type based modules on CardtypeE from type_transition
  cattr_accessor :count
end

describe "Card (Cardtype)" do
  it "should not allow cardtype remove when instances present" do
    Card.create name: "City", type: "Cardtype"
    city = Card.fetch("City")
    c1 = Card.create name: "Sparta", type: "City"
    c2 = Card.create name: "Eugene", type: "City"
    assert_equal %w(Eugene Sparta), Card.search(type: "City").map(&:name).sort
    assert_raises ActiveRecord::RecordInvalid do
      city.delete!
    end
    # make sure it wasn't deleted / trashed
    expect(Card["City"]).not_to be_nil
  end

  it "remove cardtype" do
    Card.create! name: "County", type: "Cardtype"
    c = Card["County"]
    c.delete
  end

  it "cardtype creation and dynamic cardtype" do
    assert Card.create(name: "BananaPudding", type: "Cardtype").type_id == Card::Codename[:cardtype]
    assert_instance_of Card, c = Card.fetch("BananaPudding")

    # you have to have a module to include or it's just a Basic (type_code fielde excepted)
    cd = Card.create(type: "banana_pudding", name: "figgy")
    assert cd.type_name == "BananaPudding"
    assert Card.find_by_type_id(c.id)
  end

  describe "conversion to cardtype" do
    before do
      @card = Card.create!(type: "Cardtype", name: "Cookie")
      expect(@card.type_name).to eq("Cardtype")
    end

    it "creates cardtype model and permission" do
      @card.type_id = Card.fetch_id("cookie")
      @card.save!
      expect(@card.type_name).to eq("Cookie")
      @card = Card["Cookie"]
      assert_instance_of Card, @card
      expect(@card.type_code).to eq(nil) # :cookie
      assert_equal "Cookie", Card.create!(name: "Oreo", type: "Cookie").type_name
    end
  end

  it "cardtype" do
    Card.all.each do |card|
      assert !card.type_card.nil?
    end
  end
end

describe Card, "created without permission" do
  before do
    Card::Auth.current_id = Card::AnonymousID
  end

  # FIXME:  this one should pass.  unfortunately when I tried to fix it it started looking like the clean solution
  #  was to rewrite most of the permissions section as simple validations and i decided not to go down that rabbit hole.
  #
  # it "should not be valid" do
  #  Card.new( name: 'foo', type: 'Cardtype').valid?.should_not be_true
  # end

  it "should not create a new cardtype until saved" do
    expect do
      Card.new(name: "foo", type: "Cardtype")
    end.not_to change(Card, :count)
  end
end

describe Card, "Normal card with descendants" do
  before do
    @a = Card["A"]
  end

  it "should confirm that it has descendants" do
    expect(@a.descendants.length).to be > 0
  end

  it "should successfully have its type changed" do
    Card::Auth.as_bot do
      @a.type_id = Card::PhraseID
      @a.save!
      expect(Card["A"].type_code).to eq(:phrase)
    end
  end
  it "should still have its descendants after changing type" do
    Card::Auth.as_bot do
      assert type_id = Card.fetch_id("cardtype_e")
      @a.type_id = type_id
      @a.save!
      expect(Card["A"].descendants.length).to be > 0
    end
  end
end

describe Card, "New Cardtype" do
  before do
    Card::Auth.as_bot do
      @ct = Card.create! name: "Animal", type: "Cardtype"
    end
  end

  it "should have create permissions" do
    expect(@ct.who_can(:create)).not_to be_nil
  end

  it "its create permissions should be based on Basic" do
    expect(@ct.who_can(:create)).to eq(Card["Basic"].who_can(:create))
  end
end

describe Card, "Wannabe Cardtype Card" do
  before do
    Card::Auth.as_bot do
      @card = Card.create! name: "convertible"
      @card.type_id = Card::CardtypeID
      @card.save!
    end
  end
  it "should successfully change its type to a Cardtype" do
    expect(Card["convertible"].type_code).to eq(:cardtype)
  end
end

describe Card, "Joe User" do
  before do
    Card::Auth.as_bot do
      @r3 = Card["r3"]
      Card.create name: "Cardtype F+*type+*create", type: "Pointer", content: "[[r3]]"
    end

    @ucard = Card::Auth.current
    @type_names = Card::Auth.createable_types
  end

  it "should not have r3 permissions" do
    expect(@ucard.fetch(new: {}, trait: :roles).item_names.member?(@r3.name)).to be_falsey
  end
  it "should ponder creating a card of Cardtype F, but find that he lacks create permissions" do
    expect(Card.new(type: "Cardtype F").ok?(:create)).to be_falsey
  end
  it "should not find Cardtype F on its list of createable cardtypes" do
    expect(@type_names.member?("Cardtype F")).to be_falsey
  end
  it "should find Basic on its list of createable cardtypes" do
    expect(@type_names.member?("Basic")).to be_truthy
  end
end

describe Card, "Cardtype with Existing Cards" do
  before do
    @ct = Card["Cardtype F"]
  end
  it "should have existing cards of that type" do
    expect(Card.search(type: @ct.name)).not_to be_empty
  end

  it "should raise an error when you try to delete it" do
    Card::Auth.as_bot do
      @ct.delete
      expect(@ct.errors[:cardtype]).not_to be_empty
    end
  end
end

describe Card::Set::Type::Cardtype do
  it "should handle changing away from Cardtype" do
    Card::Auth.as_bot do
      ctg = Card.create! name: "CardtypeG", type: "Cardtype"
      ctg.type_id = Card::BasicID
      ctg.save!
      ctg = Card["CardtypeG"]
      expect(ctg.type_code).to eq(:basic)
      # ctg.extension.should == nil
    end
  end
end
