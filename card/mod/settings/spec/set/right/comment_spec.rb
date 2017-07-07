# -*- encoding : utf-8 -*-

describe Card::Set::Right::Comment do
  context "record appender" do
    before do
      #      @r = Card.where(type_id: Card::RoleID).first
      @rule = Card.new name: "A+*self+*comment",
                       type_id: Card::PointerID,
                       content: "[[Anyone Signed In]]"
    end

    it "has appender immediately" do
      expect(Card["a"].ok?(:comment)).not_to be_truthy
      Card::Auth.as_bot do
        @rule.save!
      end
      expect(Card["a"].ok?(:comment)).to be_truthy
    end

    it "has appender immediately" do
      Card::Auth.as_bot do
        expect(Card["a"].ok?(:comment)).not_to be_truthy
        @rule.save!
        expect(Card["a"].ok?(:comment)).to be_truthy
      end
    end
  end

  context "comment addition" do
    it "combines content after save" do
      Card::Auth.as_bot do
        Card.create name: "basicname+*self+*comment",
                    content: "[[Anyone Signed In]]"
        Card["basicname"].update_attributes! comment: " and more\n  \nsome lines\n\n"
      end
      expect(Card["basicname"].content).to match(%r{\<p\>some lines\</p\>})
    end
  end
end
