# -*- encoding : utf-8 -*-
describe Card::Set::All::Links do
  require 'card'
  describe '#web_link' do
    it 'opens external link in new tab' do
      link = Card['Home'].format.web_link("http://example.com")
      assert_view_select link, 'a[class="external-link"][target="_blank"][href="http://example.com"]'
    end
  end
end
