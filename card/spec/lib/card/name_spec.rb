# -*- encoding : utf-8 -*-

RSpec.describe Card::Name do
  describe "#valid" do
    it "rejects long names" do
      card = Card.new
      card.name = "1" * 256
      expect(card).not_to be_valid
    end
  end

  describe "Cardnames star handling" do
    it "recognizes star cards" do
      expect("*a".to_name.star?).to be_truthy
    end

    it "doesn't recognize star cards with plusses" do
      expect("*a+*b".to_name.star?).to be_falsey
    end

    it "recognizes rstar cards" do
      expect("a+*a".to_name.rstar?).to be_truthy
    end

    it "doesn't recognize star cards as rstar" do
      expect("*a".to_name.rstar?).to be_falsey
    end

    it "doesn't recognize non-star or star left" do
      expect("*a+a".to_name.rstar?).to be_falsey
    end
  end

  describe "trait_name?" do
    it "returns true for content codename" do
      expect("bazoinga+*right+*structure".to_name.trait_name?(:structure)).to(
        be_truthy
      )
    end

    it "handles arrays" do
      structure =
        "bazoinga+*right+*structure".to_name.trait_name?(:structure, :default)
      expect(structure).to be_truthy
    end

    it "returns false for non-template" do
      structure = "bazoinga+*right+nontent".to_name.trait_name?(:structure)
      expect(structure).to be_falsey
    end
  end

  describe "#to_absolute" do
    it "does session user substitution" do
      expect("_user".to_name.to_absolute("A")).to eq(Card::Auth.current.name)
      Card::Auth.as_bot do
        expect("_user".to_name.to_absolute("A")).to eq(Card::Auth.current.name)
      end
    end
  end

  describe "part creation" do
    it "creates parts" do
      Card::Auth.as_bot do
        Card.create name: "left+right"
      end
      expect(Card.fetch("right")).to be_truthy
    end
  end

  # describe "#child_of?" do
  #   [["A+B",   "A",   true],
  #    ["A+B",   "B",   true],
  #    ["A",     "A",   false],
  #    ["A+B",   "A+B", false],
  #    ["A",     "A+B", false],
  #    ["A+C",   "A+B", false],
  #    ["A+B",   "C+B", false],
  #    ["X+A+B", "A+C", false]].each do |a, b, res|
  #     it "#{a} is a child of #{b}" do
  #       expect(a.to_name.child_of?(b)).to be res
  #     end
  #   end
  # end
  #
  # describe "#relative_name" do
  #   [["A+B",   "A",   "+B"],
  #    ["A+B",   "B",   "A"],
  #    ["A",     "A",   "A"],
  #    ["A+B",   "A+B", "A+B"],
  #    ["A",     "A+B", "A"],
  #    ["A+C",   "A+B", "+C"],
  #    ["A+B",   "C+B", "A"],
  #    ["X+A+B", "A+C", "X+B"]].each do |name, context, res|
  #     it "#{name} relative to #{context} is #{res}" do
  #       expect(name.to_name.relative_name(context).to_s).to eq res
  #     end
  #   end
  # end
end
