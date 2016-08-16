# -*- encoding : utf-8 -*-

describe Card::Set::All::Export do
  before do
    login_as "joe_user"
  end
  describe "rendering json in export mode" do
    subject do
      big_blind = Card.create! name: "special means special",
                               type_id: Card::PointerID,
                               content: "[[#{@collection_card.name}]]"
      big_blind.format(:json).render_export
    end
    context "pointer card" do
      it "should contain cards in the pointer card and its children" do
        small_blind = Card.create! name: "Elbert Hubbard",
                                   type_id: Card::BasicID,
                                   content: "Do not take life too seriously."
        small_blind_1 =
          Card.create! name: "Elbert Hubbard+hello world",
                       type_id: Card::BasicID,
                       content: "You will never get out of it alive."
        @collection_card =
          Card.create! name: "normal pointer", type_id: Card::PointerID,
                       content: "[[#{small_blind.name}]]\r\n"\
                                "[[#{small_blind_1.name}]]"

        is_expected.to include(name: "normal pointer",
                               type: "Pointer",
                               content: "[[Elbert Hubbard]]\n"\
                                        "[[Elbert Hubbard+hello world]]")
        is_expected.to include(name: "Elbert Hubbard",
                               type: "Basic",
                               content: "Do not take life too seriously.")
        is_expected.to include(name: "Elbert Hubbard+hello world",
                               type: "Basic",
                               content: "You will never get out of it alive.")
      end
      it "handles multi levels pointer cards" do
        small_blind = Card.create! name: "Elbert Hubbard",
                                   type_id: Card::BasicID,
                                   content: "Do not take life too seriously."
        inner_pointer_card = Card.create! name: "inner pointer",
                                          type_id: Card::PointerID,
                                          content: "[[#{small_blind.name}]]"
        small_blind_1 = Card.create! name: "Elbert Hubbard+hello world",
                                     type_id: Card::BasicID,
                                     content: "You will never get out of it"\
                                              " alive."
        @collection_card =
          Card.create! name: "normal pointer",
                       type_id: Card::PointerID,
                       content: "[[#{inner_pointer_card.name}""]]\r\n"\
                               "[[#{small_blind_1.name}]]"

        is_expected.to include(name: "normal pointer",
                               type: "Pointer",
                               content: "[[inner pointer]]\n"\
                                        "[[Elbert Hubbard+hello world]]")
        is_expected.to include(name: "inner pointer",
                               type: "Pointer",
                               content: "[[Elbert Hubbard]]")
        is_expected.to include(name: "Elbert Hubbard",
                               type: "Basic",
                               content: "Do not take life too seriously.")
        is_expected.to include(name: "Elbert Hubbard+hello world",
                               type: "Basic",
                               content: "You will never get out of it alive.")
      end
      it "stops while the depth count > 10" do
        @collection_card = Card.create! name: "normal pointer",
                                        type_id: Card::PointerID,
                                        content: "[[normal pointer]]"
        is_expected.to include(name: "normal pointer", type: "Pointer",
                               content: "[[normal pointer]]")
      end
    end
    context "Skin card" do
      it "should contain cards in the pointer card and its children" do
        Card::Auth.as_bot do
          small_blind =
            Card.create! name: "Elbert Hubbard",
                         type_id: Card::BasicID,
                         content: "The best thing about a boolean is "\
                         "even if you are wrong,"\
                         " you are only off by a bit"
          @collection_card = Card.create! name: "normal pointer",
                                          type_id: Card::SkinID,
                                          content: "[[#{small_blind.name}]]"

          is_expected.to include(name: "normal pointer",
                                 type: "Skin", content: "[[Elbert Hubbard]]")
          is_expected.to include(name: "Elbert Hubbard",
                                 type: "Basic",
                                 content: "The best thing about"\
                                 " a boolean is even if you are wrong, "\
                                 "you are only off by a bit")
        end
      end
    end
    context "search card" do
      it "should contain cards from search card and its children" do
        Card.create!(
          name: "Elbert Hubbard",
          type_id: Card::BasicID,
          content: "Do not take life too seriously."
        )
        Card.create!(
          name: "Elbert Hubbard+hello world",
          type_id: Card::BasicID,
          content: "You will never get out of it alive."
        )
        Card.create!(
          name: "Elbert Hubbard+quote",
          type_id: Card::BasicID,
          content: "Procrastination is the art of keeping up with yesterday."
        )
        @collection_card = Card.create! name: "search card",
                                        type_id: Card::SearchTypeID,
                                        content: %({"left":"Elbert Hubbard"})

        is_expected.to include(name: "search card",
                               type: "Search",
                               content: %({"left":"Elbert Hubbard"}))
        is_expected.to include(name: "Elbert Hubbard+hello world",
                               type: "Basic",
                               content: "You will never get out of it alive.")
        is_expected.to include(name: "Elbert Hubbard+quote",
                               type: "Basic",
                               content: "Procrastination is the art of keeping"\
                                        " up with yesterday.")
      end
    end
  end
end
