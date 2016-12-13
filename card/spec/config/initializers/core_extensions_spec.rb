# -*- encoding : utf-8 -*-

describe CoreExtensions do
  context Hash do
    describe "#new_nested" do
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

  context String do
    it "tests whether a string represents a number" do
      expect("6".number?).to eq(true)
      expect("Yomama".number?).to eq(false)
    end
  end

  context CoreExtensions::PersistentIdentifier do
    describe "#cardname" do
      subject { :wagn_bot.cardname }
      it "converts into a cardname" do
        is_expected.to be_instance_of Card::Name
        expect(subject.name).to eq "WikiRate Bot"
      end
    end

    describe "#card" do
      context "called on Integer" do
        subject { Card::ClaimID.card }
        it "converts into a card" do
          is_expected.to be_instance_of Card
          expect(subject.id).to eq Card::ClaimID
        end
      end

      context "called on Symbol" do
        subject { :claim.card }
        is_expected.to be_instance_of Card
        expect(subject.card.key).to eq(:claim.cardname.key)
      end
    end
  end
end


