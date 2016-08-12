# -*- encoding : utf-8 -*-

describe Card::Set::All::Type do
  describe "card with wagneered type" do
    before do
      Card::Auth.as_bot do
        @type = Card.create! name: "Hat", type: "Cardtype"
      end
      @hat = Card.new type: "Hat"
    end

    it "should have a type_name" do
      expect(@hat.type_name).to eq("Hat")
    end

    it "should not have a type_code" do
      expect(@hat.type_code).to eq(nil)
    end

    it "should have a type_id" do
      expect(@hat.type_id).to eq(@type.id)
    end

    it "should have a type_card" do
      expect(@hat.type_card).to eq(@type)
    end
  end

  describe "card with structured type" do
    before do
      Card::Auth.as_bot do
        Card.create! name: "Topic", type: "Cardtype"
        Card.create! name: "Topic+*type+*structure", content: "{{+results}}"
        Card.create! name: "Topic+results+*type plus right+*structure",
                     type: "Search", content: "{}"
      end
    end

    it "should clear cache of structured nested card after saving" do
      pending "need new mechanism to replace #reset_type_specific_fields"
      Card::Auth.as_bot do
        expect(Card.fetch("t1+results", new: {}).type_name).to eq("Basic")

        topic1 = Card.new type: "Topic", name: "t1"
        topic1.format._render_new
        topic1.save!
        expect(Card.fetch("t1+results", new: {}).type_name).to eq("Search")
      end
    end
  end
end
