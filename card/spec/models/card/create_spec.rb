# -*- encoding : utf-8 -*-

# FIXME: this shouldn't be here
describe Card::Set::Type::Cardtype, ".create with :codename" do
  it "should work" do
    card = Card.create! name: "Foo Type", codename: "foo",
                        type: "Cardtype"
    expect(card.type_code).to eq(:cardtype)
  end
end

describe Card, "created by Card.new" do
  before(:each) do
    Card::Auth.as_bot do
      @c = Card.new name: "New Card", content: "Great Content"
    end
  end

  it "should not override explicit content with default content" do
    Card::Auth.as_bot do
      Card.create! name: "blue+*right+*default", content: "joe", type: "Pointer"
      c = Card.new name: "Lady+blue", content: "[[Jimmy]]"
      expect(c.content).to eq("[[Jimmy]]")
    end
  end
end

describe Card, "created by Card.create with valid attributes" do
  before(:each) do
    Card::Auth.as_bot do
      @b = Card.create name: "New Card", content: "Great Content"
      @c = Card.find(@b.id)
    end
  end

  it "does not have errors" do
    expect(@b.errors.size).to eq(0)
  end
  it "has the right class" do
    expect(@c.class).to eq(Card)
  end
  it "has the right key"  do
    expect(@c.key).to eq("new_card")
  end
  it "has the right name" do
    expect(@c.name).to eq("New Card")
  end
  it "has the right content" do
    expect(@c.content).to eq("Great Content")
  end

  it "has the right content" do
    @c.db_content == "Great Content"
  end

  it "is findable by name" do
    expect(Card["New Card"].class).to eq(Card)
  end
end

describe Card, "create junction two parts" do
  before(:each) do
    @c = Card.create! name: "Peach+Pear", content: "juicy"
  end

  it "doesn't have errors" do
    expect(@c.errors.size).to eq(0)
  end

  it "creates junction card" do
    expect(Card["Peach+Pear"].class).to eq(Card)
  end

  it "creates trunk card" do
    expect(Card["Peach"].class).to eq(Card)
  end

  it "creates tag card" do
    expect(Card["Pear"].class).to eq(Card)
  end
end

describe Card, "create junction three parts" do
  it "creates very left card" do
    Card.create! name: "Apple+Peach+Pear", content: "juicy"
    expect(Card["Apple"].class).to eq(Card)
  end

  it "sets left and right ids" do
    Card.create! name: "Sugar+Milk+Flour", content: "tasty"
    sugar_milk = Card["Sugar+Milk"]
    sugar_milk_flour = Card["Sugar+Milk+Flour"]
    expect(sugar_milk_flour.left_id).to eq(sugar_milk.id)
    expect(sugar_milk_flour.right_id).to eq(Card.fetch_id("Flour"))
    expect(sugar_milk.left_id).to eq(Card.fetch_id("Sugar"))
    expect(sugar_milk.right_id).to eq(Card.fetch_id("Milk"))
  end
end

describe Card, "types" do
end
