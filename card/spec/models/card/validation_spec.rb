# -*- encoding : utf-8 -*-

describe Card, "validate name" do
  it "should error on name with /" do
    @c = Card.create name: "testname/"
    expect(@c.errors[:name]).not_to be_blank
  end

  it "should error on junction name  with /" do
    @c = Card.create name: "jasmin+ri/ce"
    expect(@c.errors[:name]).not_to be_blank
  end

  it "shouldn't create any new cards when name invalid" do
    original_card_count = Card.count
    @c = Card.create name: "jasmin+ri/ce"
    expect(Card.count).to eq(original_card_count)
  end

  it "should not allow empty name" do
    @c = Card.new name: ""
    expect(@c.valid?).to eq(false)
    expect(@c.errors[:name]).not_to be_blank
  end

  # maybe the @c.key= should just throw an error, but now it doesn't take anyway
  it "should not allow mismatched name and key" do
    @c = Card.new name: "Test"
    @c.key = "foo"
    # @c.key.should == 'test'
    expect(@c.valid?).to eq(false)
    # @c.errors[:key].should_not be_blank
  end
end
