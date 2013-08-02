# -*- encoding : utf-8 -*-
require 'wagn/pack_spec_helper'

describe Card::Set::Self::Navbox do
  it "should have a form" do
    assert_view_select render_card(:raw, :name=>'*navbox'), 'form.navbox-form'
  end
end
