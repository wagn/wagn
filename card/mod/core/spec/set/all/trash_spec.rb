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
    @name = "*all+*default"
    is_expected.to eq("#{@name} is an indestructible rule")
    expect(Card[@name]).to be
  end

  it "does not delete account with edits" do
    @name = "Joe User"
    is_expected.to match("Edits have been made with #{@name}'s user account")
    expect(Card[@name]).to be
  end

  it "deletes account without edits" do
    Card::Auth.as_bot do
      name = "born to die"
      card = Card.create! name: name, type_code: :user
      card.delete
      expect(Card[name]).not_to be
    end
  end

  it "deletes children" do
    Card::Auth.as_bot do
      name = "born to die"
      card = Card.create! name: name, "+sub" => "a subcard"
      expect(Card["#{name}+sub"]).to be
      card.delete
      expect(Card["#{name}+sub"]).not_to be
    end
  end

  it "deletes children under a set" do
    Card::Auth.as_bot do
      type = Card.create! name: "Metric Value", type_id: Card::CardtypeID
      Card.create! name: "Metric value+value+*type plus right",
                   type_id: Card::SetID
      mv1_name = "Richard Mills+Annual Sales+CA+2014"
      mv2_name = "Richard Mills+Annual Profits+CA+2014"
      Card.create! name: mv1_name, type_id: type.id
      Card.create! name: mv2_name, type_id: type.id
      Card.create! name: "#{mv1_name}+value", type_id: Card::BasicID
      Card.create! name: "#{mv2_name}+value", type_id: Card::BasicID

      expect(Card["CA"]).to be
      Card["CA"].delete
      expect(Card["CA"]).not_to be
      expect(Card[mv1_name]).not_to be
      expect(Card["#{mv1_name}+value"]).not_to be
      expect(Card[mv2_name]).not_to be
      expect(Card["#{mv2_name}+value"]).not_to be
    end
  end

  it "deletes account of user" do
    Card::Auth.as_bot do
      @signup = Card.create!(
        name: "born to die", type_id: Card::SignupID,
        "+*account" => { "+*email" => "wolf@wagn.org", "+*password" => "wolf" }
      )
      @signup.update_attributes!({})
    end
    Card::Cache.reset_all

    Card::Auth.as_bot do
      expect(Card.search(right: "*account")).not_to be_empty
      Card["born to die"].delete!
    end
    expect(Card["born to die+*account"]).not_to be
  end
end
