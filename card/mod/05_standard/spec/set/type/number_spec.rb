# -*- encoding : utf-8 -*-

describe Card::Set::Type::Number do
  it "should have special editor" do
    assert_view_select render_editor("Number"), 'input[type="text"]'
  end
end
