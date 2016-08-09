# -*- encoding : utf-8 -*-

describe Card::Codename, "Codename" do
  before do
    @codename = :default
  end

  it "should be sane" do
    expect(Card[@codename].codename).to eq(@codename.to_s) # would prefer Symbol eventually
    card_id = Card::Codename[@codename]
    expect(card_id).to be_a_kind_of Integer
    expect(Card::Codename[card_id]).to eq(@codename)
  end

  it "should make cards indestructable" do
    Card::Auth.as_bot do
      card = Card[@codename]
      card.delete
      expect(card.errors[:delete].first).to match "is a system card"
      expect(Card[@codename]).to be
    end
  end
end
