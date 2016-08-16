# -*- encoding : utf-8 -*-

describe Card::Set::Type::LayoutType do
  it "should include Html card methods" do
    expect(Card.new(type: "Layout").clean_html?).to be_falsey
  end
end
