# -*- encoding : utf-8 -*-

describe Card::Set::Type::LayoutType do
  it "includes Html card methods" do
    expect(Card.new(type: "Layout").clean_html?).to be_falsey
  end
end
