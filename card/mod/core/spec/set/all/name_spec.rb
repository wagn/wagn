# -*- encoding : utf-8 -*-

describe Card::Set::All::Name do
  describe "autoname" do
    before do
      Card::Auth.as_bot do
        @b1 = Card.create! name: "Book+*type+*autoname", content: "b1"
      end
    end

    it "should handle cards without names" do
      c = Card.create! type: "Book"
      expect(c.name).to eq("b1")
    end

    it "should increment again if name already exists" do
      _b1 = Card.create! type: "Book"
      b2 = Card.create! type: "Book"
      expect(b2.name).to eq("b2")
    end

    it "should handle trashed names" do
      b1 = Card.create! type: "Book"
      Card::Auth.as_bot { b1.delete }
      b1 = Card.create! type: "Book"
      expect(b1.name).to eq("b1")
    end
  end

  describe "codename" do
    before :each do
      @card = Card["a"]
    end

    it "should require admin permission" do
      @card.update_attributes codename: "structure"
      expect(@card.errors[:codename].first).to match(/only admins/)
    end

    it "should check uniqueness" do
      Card::Auth.as_bot do
        @card.update_attributes codename: "structure"
        expect(@card.errors[:codename].first).to match(/already in use/)
      end
    end
  end

  describe "repair_key" do
    it "should fix broken keys" do
      a = Card["a"]
      a.update_column "key", "broken_a"
      a.expire

      a = Card.find a.id
      expect(a.key).to eq("broken_a")
      a.repair_key
      expect(a.key).to eq("a")
    end
  end
end
