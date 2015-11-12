# -*- encoding : utf-8 -*-

describe Card::Set::All::Trash do
  subject do
    card = Card[@name]
    Card::Auth.as_bot do
      card.delete
    end
    card.errors[:delete].first
  end

  it "certain 'all rules' should be indestructable" do
    @name = '*all+*default'
    is_expected.to eq("#{@name} is an indestructible rule")
    expect(Card[@name]).to be
  end

  it 'does not delete account with edits' do
    @name = 'Joe User'
    is_expected.to match("Edits have been made with #{@name}'s user account")
    expect(Card[@name]).to be
  end

  it 'deletes account without edits' do
    Card::Auth.as_bot do
      name = 'born to die'
      card = Card.create! name: name, type_code: :user
      card.delete
      expect(Card[name]).not_to be
    end
  end

  it 'deletes children' do
    Card::Auth.as_bot do
      name = 'born to die'
      card = Card.create! name: name, '+sub' => 'a subcard'
      expect(Card["#{name}+sub"]).to be
      card.delete
      expect(Card["#{name}+sub"]).not_to be
    end
  end

  it 'deletes children of a middle child' do
    Card::Auth.as_bot do
      name = 'born to die'
      Card.create! name: name, '+sub' => 'a subcard'
      Card.create! name: name + '+sub+s1', content: 'sigh'
      Card.create! name: name + '+sub+s1+s2', content: 'sigh again'
      Card.create! name: name + '+sub+s1+s2+s3', content: 'sigh again again'
      expect(Card['sub']).to be
      Card['sub'].delete
      expect(Card["#{name}+sub"]).not_to be
      expect(Card["#{name}+sub+s1"]).not_to be
      expect(Card["#{name}+sub+s1+s2"]).not_to be
      expect(Card["#{name}+sub+s1+s2+s3"]).not_to be
      
    end
  end

  it 'deletes account of user' do
    Card::Auth.as_bot do
      @signup = Card.create!(
        name: 'born to die', type_id: Card::SignupID,
        '+*account' => { '+*email' => 'wolf@wagn.org', '+*password' => 'wolf' }
      )
      @signup.update_attributes!({})
    end
    Card::Cache.reset_global

    Card::Auth.as_bot do
      expect(Card.search :right=>'*account').not_to be_empty
      Card['born to die'].delete!
    end
    expect(Card['born to die+*account']).not_to be
  end
end
