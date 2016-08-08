# -*- encoding : utf-8 -*-

describe Card::Set::Right::Create do
  it "should render the perm editor" do
    Card::Auth.as_bot do
      card = Card.new name: "A+B+*self+*create"
      assert_view_select card.format._render_editor, "div[class=perm-editor]"
    end
  end
end
