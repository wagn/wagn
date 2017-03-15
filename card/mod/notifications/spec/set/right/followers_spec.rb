# -*- encoding : utf-8 -*-

describe Card::Set::Right::Followers do
  describe "#raw_content" do
    it "returns a pointer list of followers" do
      card = Card.fetch "All Eyes on me"
      expect(card.followers_card.item_names.sort)
        .to eq ["Big Brother", "John", "Sara"]
    end
  end

  describe "view :core" do
    it "contains follower" do
      card = Card.fetch "All Eyes on me"
      view = card.followers_card.format.render_core
      expect(view).to include("Sara")
    end
  end

  describe "view :raw" do
    it "renders a pointer list of followers" do
      card = Card.fetch "All Eyes on me"
      view = card.followers_card.format.render_raw
      expect(view.split("\n").sort)
        .to eq ["[[Big Brother]]", "[[John]]", "[[Sara]]"]
    end
  end

  describe "item_names" do
    subject { @card.followers_card.item_names.sort }
    it "is an array of followers" do
      @card = Card["All Eyes On Me"]
      is_expected.to eq ["Big Brother", "John", "Sara"]
    end

    it "recognizes card name changes" do
      @card = Card["Look At Me"]
      @card.update_referers = true
      @card.update_attributes! name: "Look away"
      is_expected.to eq ["Big Brother"]
    end

    it "recognizes +*following changes" do
      Card::Auth.as_bot do
        card = Card["Joe User"].follow "Look At Me"
      end
      @card = Card["Look At Me"]
      is_expected.to include "Joe User"
    end

    context "when following a card" do
      it "contains follower" do
        @card = Card["All Eye On Me"]
        is_expected.to include("Big Brother")
      end
    end

    context "when following a *self set" do
      it "contains follower" do
        @card = Card["Look At Me"]
        is_expected.to include("Big Brother")
      end
    end

    context "when following a *type set" do
      it "contains follower" do
        @card = Card.create! name: "telescope", type: "Optic"
        is_expected.to include("Big Brother")
      end
    end

    context "when following a *right set" do
      it "contains follower" do
        @card = Card.create! name: "telescope+lens"
        is_expected.to include("Big Brother")
      end
    end

    context "when following a *type plus right set" do
      it "contains follower" do
        @card = Card["Sunglasses+tint"]
        is_expected.to include("Big Brother")
      end
    end

    context "when following content I created" do
      it "contains creator" do
        Card::Auth.current_id = Card["Big Brother"].id
        @card = Card.create! name: "created by Follower"
        is_expected.to include("Big Brother")
      end
    end

    context "when following content I edited" do
      it "contains editor" do
        Card::Auth.as_bot do
          Card["Sara"].follow "*all", "*edited"
        end

        @card = Card.create! name: "edited by Sara"
        Card::Auth.current_id = Card["Sara"].id
        @card.update_attributes! content: "some content"
        is_expected.to include("Sara")
      end
    end

    context "for a set card" do
      it "contains followers of that set" do
        @card = Card["lens+*right"]
        is_expected.to include("Big Brother")
      end
    end

    context "for a type card" do
      it "contains followers of that type" do
        @card = Card["Optic"]
        is_expected.to include("Optic fan")
      end
    end
  end
end
