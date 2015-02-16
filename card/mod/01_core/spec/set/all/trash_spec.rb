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
  
  it 'does not delete account with edits' do
    Card::Auth.as_bot do
      name = 'Joe User'
      card = Card[name]
      card.delete
      expect(card.errors[:delete].first).to match("Edits have been made with #{name}'s user account")
      expect(Card[name]).to be
    end
  end
  
  it 'deletes account without edits' do
    Card::Auth.as_bot do
      name = 'born to die'
      card = Card.create! :name=>name, :type_code=>:user
      card.delete
      expect(Card[name]).not_to be
    end
  end

end
