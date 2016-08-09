# -*- encoding : utf-8 -*-

describe Card::Set::Right::Email do
  context "<User>+*email" do
    before do
      @card = Card.fetch "u1+*email"
      @format = @card.format
    end

    it "should allow Wagn Bot to read" do
      Card::Auth.as_bot do
        expect(@format.render_raw).to eq("u1@user.com")
      end
    end

    it "should allow self to read" do
      Card::Auth.as Card["u1"] do
        expect(@format.render_raw).to eq("u1@user.com")
      end
    end

    it "should hide from other users" do
      expect(@card.ok?(:read)).to be_falsey
      expect(@format.render_raw).to match(/denied/)
    end
  end

  context "+*account+*email" do
    context "update" do
      before :each do
        @email_card = email_card = Card["u1"].account.email_card
      end

      it "should downcase email" do
        Card::Auth.as_bot do
          @email_card.update_attributes! content: "QuIrE@example.com"
          expect(@email_card.content).to eq("quire@example.com")
        end
      end

      it "should require valid email" do
        @email_card.update_attributes content: "boop"
        expect(@email_card.errors[:content].first).to match(/must be valid address/)
      end

      it "should require unique email" do
        @email_card.update_attributes content: "joe@user.com"
        expect(@email_card.errors[:content].first).to match(/must be unique/)
      end
    end
  end
end
