# -*- encoding : utf-8 -*-

describe Card::Set::Self::Navbox do
  it "should have a form" do
    assert_view_select render_card(:core, name: "*navbox"), "form.navbox-form input.navbox"
  end
end
