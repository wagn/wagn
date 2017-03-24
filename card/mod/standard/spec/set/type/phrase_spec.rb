# -*- encoding : utf-8 -*-

describe Card::Set::Type::Phrase do
  it "has special editor" do
    assert_view_select render_editor("Phrase"),
                       'input[type="text"][class~="card-content"]'
  end
end
