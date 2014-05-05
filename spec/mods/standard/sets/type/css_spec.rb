# -*- encoding : utf-8 -*-

describe Card::Set::Type::Css do
  it "should highlight code" do
    Card::Auth.as_bot do
      css_card = Card.create! :name=>'tmp css', :type_code=>'css', :content=>"p { border: 1px solid black }"
      assert_view_select css_card.format.render_core, 'div[class=CodeRay]'
    end
  end
end
