# -*- encoding : utf-8 -*-

describe Card::Set::All::References do
  it "should replace references should work on nests inside links" do
    card = Card.create! name: "ref test", content: "[[test_card|test{{test}}]]"
    assert_equal "[[test_card|test{{best}}]]",
                 card.replace_reference_syntax("test", "best")
  end
end
