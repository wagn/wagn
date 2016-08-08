# -*- encoding : utf-8 -*-

describe Card::Set::Self::Head do
  it "should have a javascript tag" do
    assert_view_select render_card(:raw, name: "*head"), 'script[type="text/javascript"]'
  end

  context "tinyMCE config" do
    before do
      @tinyMCE = Card[:tiny_mce]
    end
    it "should handle tinyMCE configuration errors" do
    end
  end
end
