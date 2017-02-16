# -*- encoding : utf-8 -*-

require 'rspec'

RSpec.describe Card::Name do
  describe "#key" do
    it "lowercases and underscores" do
      expect("This Name".to_name.key).to eq("this_name")
    end

    it "removes spaces" do
      expect("this    Name".to_name.key).to eq("this_name")
    end

    describe "underscores" do
      it "is treated like spaces" do
        expect("weird_ combo".to_name.key).to eq("weird  combo".to_name.key)
      end

      it "does not impede pluralization checks" do
        expect("Mamas_and_Papas".to_name.key).to(
          eq("Mamas and Papas".to_name.key)
        )
      end

      it "is removed when before first word character" do
        expect("_This Name".to_name.key).to eq("this_name")
      end
    end

    it "singularizes" do
      expect("ethans".to_name.key).to eq("ethan")
    end

    it "changes CamelCase to snake case" do
      expect("ThisThing".to_name.key).to eq("this_thing")
    end

    it "handles plus cards" do
      expect("ThisThing+Ethans".to_name.key).to eq("this_thing+ethan")
    end

    it "retains * for star cards" do
      expect("*right".to_name.key).to eq("*right")
    end

    it "does not singularize double s's" do
      expect("grass".to_name.key).to eq("grass")
    end

    it "does not singularize letter 'S'" do
      expect("S".to_name.key).to eq("s")
    end

    it "handles unicode characters" do
      expect("Mañana".to_name.key).to eq("mañana")
    end

    it "handles weird initial characters" do
      expect("__you motha @\#$".to_name.key).to eq("you_motha")
      expect("?!_you motha @\#$".to_name.key).to eq("you_motha")
    end

    it "allows numbers" do
      expect("3way".to_name.key).to eq("3way")
    end

    it "internal plurals" do
      expect("cards hooks label foos".to_name.key).to eq("card_hook_label_foo")
    end

    it "handles html entities" do
      # This no longer takes off the s, is singularize broken now?
      expect("Jean-fran&ccedil;ois Noubel".to_name.key).to(
        eq("jean_françoi_noubel")
      )
    end
  end

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
end
