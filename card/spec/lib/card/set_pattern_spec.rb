# -*- encoding : utf-8 -*-

module SetPatternSpecHelper
  def it_generates opts
    name = opts[:name]
    card = opts[:from]
    it "generates name '#{name}' for card '#{card.name}'" do
      expect(described_class.new(card).to_s).to eq(name)
    end
  end
end

include SetPatternSpecHelper

describe Card::SetPattern do
end

# FIXME: - these should probably be in pattern-specific specs, though that may not leave much to test in the base class :)

describe Card::RightSet do
  it_generates name: "author+*right", from: Card.new(name: "Iliad+author")
  it_generates name: "author+*right", from: Card.new(name: "+author")
end

describe Card::TypeSet do
  it_generates name: "Book+*type", from: Card.new(type: "Book")
end

describe Card::TypeSet do
  before :each do
    Card::Auth.as_bot do
      @mylist = Card.create! name: "MyList", type_id: Card::CardtypeID
      Card.create name: "MyList+*type+*default", type_id: Card::PointerID
    end
    @mylist_card = Card.create name: "ip", type_id: @mylist.id
  end
  # similar tests for an inherited type of Pointer
  it "has inherited set module" do
    expect(@mylist_card.set_format_modules(Card::HtmlFormat)).to include(Card::Set::Type::Pointer::HtmlFormat)
    expect(@mylist_card.set_format_modules(Card::CssFormat)).to include(Card::Set::Type::Pointer::CssFormat)
    expect(@mylist_card.set_format_modules(Card::JsFormat)).to include(Card::Set::Type::Pointer::JsFormat)
    expect(@mylist_card.set_modules).to include(Card::Set::Type::Pointer)
  end
end

describe Card::AllPlusSet do
  it_generates name: "*all plus", from: Card.new(name: "Book+author")
end

describe Card::AllSet do
  it_generates name: "*all", from: Card.new(type: "Book")
end

describe Card::TypePlusRightSet do
  author_card = Card.new(name: "Iliad+author")
  it_generates name: "Book+author+*type plus right", from: author_card
end
