# -*- encoding : utf-8 -*-

# FIXME this shouldn't be here
describe Card::Set::Type::Cardtype, ".create with :codename" do
  it "should work" do
    expect(Card.create!(:name=>"Foo Type", :codename=>"foo", :type=>'Cardtype').type_code).to eq(:cardtype)
  end
end




describe Card, "created by Card.new " do
  before(:each) do
    Card::Auth.as_bot do
      @c = Card.new :name=>"New Card", :content=>"Great Content"
    end
  end

  it "should not override explicit content with default content" do
    Card::Auth.as_bot do
      Card.create! :name => "blue+*right+*default", :content => "joe", :type=>"Pointer"
      c = Card.new :name => "Lady+blue", :content => "[[Jimmy]]"
      expect(c.content).to eq("[[Jimmy]]")
    end
  end
end



describe Card, "created by Card.create with valid attributes" do
  before(:each) do
    Card::Auth.as_bot do
      @b = Card.create :name=>"New Card", :content=>"Great Content"
      @c = Card.find(@b.id)
    end
  end

  it "should not have errors"        do expect(@b.errors.size).to eq(0)        end
  it "should have the right class"   do expect(@c.class).to    eq(Card) end
  it "should have the right key"     do expect(@c.key).to      eq("new_card")  end
  it "should have the right name"    do expect(@c.name).to     eq("New Card")  end
  it "should have the right content" do expect(@c.content).to  eq("Great Content") end

  it "should have the right content" do
    @c.db_content == "Great Content"
  end

  it "should be findable by name" do
    expect(Card["New Card"].class).to eq(Card)
  end
end


describe Card, "create junction" do
  before(:each) do
    @c = Card.create! :name=>"Peach+Pear", :content=>"juicy"
  end

  it "should not have errors" do
    expect(@c.errors.size).to eq(0)
  end

  it "should create junction card" do
    expect(Card["Peach+Pear"].class).to eq(Card)
  end

  it "should create trunk card" do
    expect(Card["Peach"].class).to eq(Card)
  end

  it "should create tag card" do
    expect(Card["Pear"].class).to eq(Card)
  end
end



describe Card, "types" do

end

