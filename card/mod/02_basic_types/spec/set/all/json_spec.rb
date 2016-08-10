# -*- encoding : utf-8 -*-

describe Card::Set::All::Json, "JSON mod" do
  context "status view" do
    it "should handle real and virtual cards" do
      jf = Card::JsonFormat
      real_json = jf.new(Card["T"]).show :status, {}
      expect(JSON[real_json]).to eq(
        "key" => "t", "status" => "real", "id" => Card["T"].id, "url_key" => "T"
      )
      virtual_json = jf.new(Card.fetch("T+*self")).show :status, {}
      expect(JSON[virtual_json]).to eq(
        "key" => "t+*self", "status" => "virtual", "url_key" => "T+*self"
      )
    end

    it "should treat both unknown and unreadable cards as unknown" do
      Card::Auth.as Card::AnonymousID do
        jf = Card::JsonFormat

        unknown = Card.new name: "sump"
        unreadable = Card.new name: "kumq", type: "Fruit"
        unknown_json = jf.new(unknown).show :status, {}
        expect(JSON[unknown_json]).to eq(
          "key" => "sump", "status" => "unknown", "url_key" => "sump"
        )
        unreadable_json = jf.new(unreadable).show :status, {}
        expect(JSON[unreadable_json]).to eq(
          "key" => "kumq", "status" => "unknown", "url_key" => "kumq"
        )
      end
    end
  end
end
