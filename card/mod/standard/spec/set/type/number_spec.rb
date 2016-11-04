# -*- encoding : utf-8 -*-

describe Card::Set::Type::Number do
  it "has special editor" do
    assert_view_select render_editor("Number"), 'input[type="text"]'
  end
end
