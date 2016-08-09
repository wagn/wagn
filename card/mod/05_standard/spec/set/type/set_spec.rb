# -*- encoding : utf-8 -*-

describe Card::Set::Type::Set do
  describe :junction_only? do
    it "should identify sets that only apply to plus cards" do
      expect(Card.fetch("*all").junction_only?).to be_falsey
      expect(Card.fetch("*all plus").junction_only?).to be_truthy
      expect(Card.fetch("Book+*type").junction_only?).to be_falsey
      expect(Card.fetch("*to+*right").junction_only?).to be_truthy
      expect(Card.fetch("Book+*to+*type plus right").junction_only?).to be_truthy
    end
  end

  describe :inheritable? do
    it "should identify sets that can inherit rules" do
      expect(Card.fetch("A+*self").inheritable?).to be_falsey
      expect(Card.fetch("A+B+*self").inheritable?).to be_truthy
      expect(Card.fetch("Book+*to+*type plus right").inheritable?).to be_truthy
      expect(Card.fetch("Book+*type").inheritable?).to be_falsey
      expect(Card.fetch("*to+*right").inheritable?).to be_truthy
      expect(Card.fetch("*all plus").inheritable?).to be_truthy
      expect(Card.fetch("*all").inheritable?).to be_falsey
    end
  end
end
