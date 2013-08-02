# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Self::AccountLinks do
  it "should have a 'my card' link" do
    assert_view_select render_card(:raw, :name=>'*account links'), 'span[id="logging"]' do
      assert_select 'a[id="my-card-link"]', :text => 'Joe User'
    end
  end
end
