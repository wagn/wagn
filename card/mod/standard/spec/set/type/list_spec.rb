# -*- encoding : utf-8 -*-

describe Card::Set::Type::List do
  subject { Card.fetch("Parry Hotter+authors").item_names.sort }
  before do
    Card::Auth.as_bot do
      Card.create! name: "Stam Broker+books", type: "listed by"
      Card.create!(
        name: "Parry Hotter+authors",
        content: "[[Darles Chickens]]\n[[Stam Broker]]",
        type: "list"
      )
    end
  end
  describe "Parry Hotter+authors" do
    context "when 'Parry Hotter' is added to Joe-Ann Rolwings's books" do
      before do
        Card.create! name: "Joe-Ann Rolwing", type: "author"
        Card.create!(
          name: "Joe-Ann Rolwing+books", type: "listed by",
          content: "[[Parry Hotter]]"
        )
      end
      it do
        is_expected.to eq(
          ["Darles Chickens", "Joe-Ann Rolwing", "Stam Broker"]
        )
      end
    end

    context "when 'Parry Hotter' is dropped from Stam Brokers's books" do
      before do
        Card::Auth.as_bot do
          Card["Stam Brokers+books"].update_attributes!(
            content: "[[50 grades of shy]]"
          )
        end
      end
      it { is_expected.to eq ["Darles Chickens"] }
    end
    context "when Stam Broker is deleted" do
      before do
        Card["Stam Broker"].delete
      end
      it { is_expected.to eq ["Darles Chickens", "Stam Broker"] }
    end
    context "when the cardtype of Stam Broker changed" do
      it "raises an error" do
        @card = Card["Stam Broker"]
        @card.update_attributes type_id: Card::BasicID
        expect(@card.errors[:type].first).to match(
          /can't be changed because .+ is referenced by list/
        )
      end
    end
    context "when the name of Parry Hotter changed to Parry Moppins" do
      before do
        Card["Parry Hotter"].update_attributes! name: "Parry Moppins"
      end
      subject do
        Card.fetch("Parry Moppins+authors").item_names.sort
      end
      it { is_expected.to eq ["Darles Chickens", "Stam Broker"] }
    end

    context "when the name of Stam Broker changed to Stam Trader" do
      before do
        Card["Stam Broker"].update_attributes!(
          name: "Stam Trader", update_referers: true
        )
      end
      it { is_expected.to eq ["Darles Chickens", "Stam Trader"] }
    end

    # if content is invalid then fail
    context "when Stam Broker+books changes to Stam Broker+poems" do
      it "raises error because content is invalid" do
        expect do
          Card["Stam Broker+books"].update_attributes! name: "Stam Broker+poems"
        end.to raise_error
      end
    end
    context "when Stam Broker+books changes to Stam Broker+not a type" do
      it "raises error because name needs cardtype name as right part" do
        expect do
          Card["Stam Broker+books"].update_attributes!(
            name: "Stam Broker+not a type"
          )
        end.to raise_error
      end
    end

    context "when the cartype of Parry Hotter changed" do
      before do
        Card["Parry Hotter"].update_attributes! type_id: Card::BasicID
      end
      it { is_expected.to eq ["Darles Chickens", "Stam Broker"] }
    end
    context "when Parry Hotter+authors to Parry Hotter+basics" do
      it "raises error because content is invalid" do
        expect do
          Card["Parry Hotter+authors"].update_attributes!(
            name: "Parry Hotter+basics"
          )
        end.to raise_error
      end
    end
  end

  describe "'listed by' entry added that doesn't have a list" do
    context "when '50 grades of shy is added to Stam Broker's books" do
      before do
        Card["Stam Broker+books"].add_item! "50 grades of shy"
      end
      it "creates '50 grades of shy+authors" do
        authors = Card["50 grades of shy+authors"]
        expect(authors).to be_truthy
        expect(authors.item_names).to eq ["Stam Broker"]
      end
    end
  end

  context "when the name of the cardtype books changed" do
    before do
      Card["book"].update_attributes!(
        type_id: Card::BasicID, update_referers: true
      )
    end
    it { is_expected.to eq ["Darles Chickens", "Stam Broker"] }
  end

  context "when the name of the cardtype authors changed" do
    before do
      Card["author"].update_attributes!(
        type_id: Card::BasicID, update_referers: true
      )
    end
    it { is_expected.to eq ["Darles Chickens", "Stam Broker"] }
  end
end
