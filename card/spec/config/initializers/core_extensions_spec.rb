# -*- encoding : utf-8 -*-

describe Hash do
  describe "new_nested" do
    it "creates nested hashes" do
      nested_hash = Hash.new_nested Hash, Hash
      expect(nested_hash[:a]).to be_instance_of Hash
      expect(nested_hash[:a][:b]).to be_instance_of Hash
      expect(nested_hash[:d][:c]).to be_instance_of Hash
    end

    it "creates set in hash" do
      nested_hash = Hash.new_nested ::Set
      expect(nested_hash[:a]).to be_instance_of ::Set
    end
  end
end

describe CoreExtensions::PersistentIdentifier do
  describe ::Symbol do
    it "converts into a cardname" do
      expect(:wagn_bot.cardname.s).to eq("Wagn Bot")
    end

    it "converts into a card" do
      expect(:logo.card.id).to eq(Card::LogoID)
      expect(:logo.card.key).to eq(:logo.cardname.key)
    end
  end

  describe ::Integer do
    it "converts into a card" do
      expect(Card::LogoID.card.id).to eq(Card::LogoID)
    end
  end
end
