# -*- encoding : utf-8 -*-
require 'wagn/pack_spec_helper'

describe Card::Set::Self::Head do
  it "should have a javascript tag" do
    assert_view_select render_card(:raw, :name=>'*head'), 'script[type="text/javascript"]'
  end
end
