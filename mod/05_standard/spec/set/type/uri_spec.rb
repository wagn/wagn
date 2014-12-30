# -*- encoding : utf-8 -*-

describe Card::Set::Type::Uri do
  it "should have special editor" do
    assert_view_select render_editor('Uri'), 'input[type="text"][class="card-content"]'
  end
end
