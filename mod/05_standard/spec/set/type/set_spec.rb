# -*- encoding : utf-8 -*-

describe Card::Set::Type::Set do
  
  describe :junction_only? do
    it "should identify sets that only apply to plus cards" do
      Card.fetch("*all").junction_only?.should be_false
      Card.fetch("*all plus").junction_only?.should be_true
      Card.fetch("Book+*type").junction_only?.should be_false
      Card.fetch("*to+*right").junction_only?.should be_true
      Card.fetch("Book+*to+*type plus right").junction_only?.should be_true
    end
  end
  
  describe :inheritable? do
    it "should identify sets that can inherit rules" do
      Card.fetch("A+*self").inheritable?.should be_false
      Card.fetch("A+B+*self").inheritable?.should be_true
      Card.fetch("Book+*to+*type plus right").inheritable?.should be_true
      Card.fetch("Book+*type").inheritable?.should be_false
      Card.fetch("*to+*right").inheritable?.should be_true
      Card.fetch("*all plus").inheritable?.should be_true
      Card.fetch("*all").inheritable?.should be_false
    end
  end
end