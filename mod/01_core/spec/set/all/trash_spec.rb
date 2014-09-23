# -*- encoding : utf-8 -*-

describe Card::Set::All::Trash do
  
  it "certain 'all rules' should be indestructable" do
    Card::Auth.as_bot do
      name = '*all+*default'
      card = Card[name]
      card.delete
      expect(card.errors[:delete].first).to eq("#{name} is an indestructible rule")
      expect(Card[name]).to be
    end
  end

end
