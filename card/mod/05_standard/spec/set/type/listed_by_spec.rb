# -*- encoding : utf-8 -*-

describe Card::Set::Type::ListedBy do
  let(:listed_by) { Card.fetch("Darles Chickens+books").item_names.sort }
  before do
    Card::Auth.as_bot do
      Card.create!(
        name: "Parry Hotter+authors",
        content: "[[Darles Chickens]]",
        type: "list"
      )
      Card.create!(
        name: "50 grades of shy+authors",
        content: "[[Darles Chickens]]\n[[Stam Broker]]",
        type: "list"
      )
    end
  end
  it "doesn't allow non-cardtype as right part" do
    expect do
      Card["Parry Hotter+authors"].update_attributes!(
        name: "Parry Hotter+hidden"
      )
    end.to raise_error
  end

  context 'when Darles Chickens is in the author list of \
           "Parry Hotter" and "50 grades of shy"' do
    describe "Darles Chickens+books" do
      subject { listed_by }
      it { is_expected.to eq ["50 grades of shy", "Parry Hotter"] }

      it "is recorded in the reference table" do
        search_result = Card.search(
          right_plus: ["books", link_to: "50 grades of shy"],
          return: :name
        )
        expect(search_result.sort).to eq ["Darles Chickens", "Stam Broker"]
      end

      context "when Darles Chickens is removed from Parry Hotter's list" do
        before do
          Card["Parry Hotter+authors"].update_attributes!(
            content: "[[Stam Broker]]"
          )
        end
        it { is_expected.to eq ["50 grades of shy"] }
      end
      context "when Parry Hotter is deleted" do
        before do
          Card["Parry Hotter"].delete
        end
        it { is_expected.to eq ["50 grades of shy"] }
      end
      context "when a new book is created that lists Darles Chickens" do
        before do
          Card::Auth.as_bot do
            Card.create!(
              name: "Adventures of Buckleharry Finn",
              type: "book",
              subcards: {
                "+authors" => { content: "[[Darles Chickens]]", type: "list" }
              }
            )
          end
        end
        it do
          is_expected.to eq(
            ["50 grades of shy", "Adventures of Buckleharry Finn", "Parry Hotter"]
          )
        end
      end
      context "when Darles Chickens is added to a book's list" do
        before do
          Card::Auth.as_bot do
            Card.create!(
              name: "Adventures of Buckleharry Finn",
              type: "book",
              subcards: {
                "+authors" => { content: "[[Stam Broker]]", type: "list" }
              }
            )
            Card.fetch("Adventures of Buckleharry Finn+authors")
                .update_attributes!(content: "[[Darles Chickens]]")
          end
        end
        it do
          is_expected.to eq(
            [
              "50 grades of shy",
              "Adventures of Buckleharry Finn",
              "Parry Hotter"
            ]
          )
        end
      end

      context "when the cardtype of Parry Hotter changed" do
        before do
          Card["Parry Hotter"].update_attributes! type_id: Card::BasicID
        end
        it { is_expected.to eq ["50 grades of shy"] }
      end
      context "when the name of Parry Hotter changed to Parry Moppins" do
        before do
          Card::Auth.as_bot do
            Card["Parry Hotter"].update_attributes!(
              name: "Parry Moppins",
              update_referers: true
            )
          end
        end
        it { is_expected.to eq ["50 grades of shy", "Parry Moppins"] }
      end

      context "when the name of Darles Chickens changed" do
        before do
          Card["Darles Chickens"].update_attributes!(
            name: "Darles Eggs",
            update_referers: true
          )
        end
        subject { Card.fetch("Darles Eggs+books").item_names.sort }
        it { is_expected.to eq ["50 grades of shy", "Parry Hotter"] }
      end
      context "when the cartype of Darles Chickens changed" do
        it "raises error" do
          expect do
            Card["Darles Chickens"].update_attributes! type_id: Card::BasicID
          end.to raise_error
        end
      end
      context "when the name of Darles Chickens+books changed" do
        subject { Card.fetch("Darles Chickens+authors").item_names.sort }
        before do
          Card["Darles Chickens+books"].update_attributes!(
            name: "Darles Chickens+authors"
          )
        end
        it { is_expected.to eq [] }
      end
      context "when the name of the cardtype books changed" do
        before do
          Card["book"].update_attributes! name: "literature"
        end
        subject { Card.fetch("Darles Chickens+literature").item_names.sort }
        it { is_expected.to eq ["50 grades of shy", "Parry Hotter"] }
      end
      context "when the name of the cardtype authors changed" do
        before do
          Card["author"].update_attributes! type_id: Card::BasicID
        end
        it { is_expected.to eq ["50 grades of shy", "Parry Hotter"] }
      end
    end
  end
end
