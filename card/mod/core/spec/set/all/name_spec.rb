# -*- encoding : utf-8 -*-

describe Card::Set::All::Name do
  describe "autoname" do
    before do
      Card::Auth.as_bot do
        @b1 = Card.create! name: "Book+*type+*autoname", content: "b1"
      end
    end

    it "handles cards without names" do
      c = Card.create! type: "Book"
      expect(c.name).to eq("b1")
    end

    it "increments again if name already exists" do
      _b1 = Card.create! type: "Book"
      b2 = Card.create! type: "Book"
      expect(b2.name).to eq("b2")
    end

    it "handles trashed names" do
      b1 = Card.create! type: "Book"
      Card::Auth.as_bot { b1.delete }
      b1 = Card.create! type: "Book"
      expect(b1.name).to eq("b1")
    end
  end

  describe "codename" do
    before do
      @card = Card["a"]
    end

    it "requires admin permission" do
      @card.update_attributes codename: "structure"
      expect(@card.errors[:codename].first).to match(/only admins/)
    end

    it "checks uniqueness" do
      Card::Auth.as_bot do
        @card.update_attributes codename: "structure"
        expect(@card.errors[:codename].first).to match(/already in use/)
      end
    end
  end

  describe "repair_key" do
    it "fixes broken keys" do
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
