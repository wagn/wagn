# -*- encoding : utf-8 -*-

describe Card::Set::All::Links do
  require "card"
  describe "#link_to_resource" do
    it "opens external link in new tab" do
      actual = Card["Home"].format.link_to_resource "http://example.com"
      expected = 'a[class="external-link"][target="_blank"]' \
                 '[href="http://example.com"]'
      assert_view_select actual, expected
    end

    it "opens interal link in same tab" do
      actual = Card["Home"].format.link_to_resource "/Home"
      expected = 'a[target="_blank"]'
      assert_view_select actual, expected, false
    end
  end
end
