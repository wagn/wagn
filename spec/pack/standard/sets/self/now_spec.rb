# -*- encoding : utf-8 -*-
require 'wagn/pack_spec_helper'

describe Card::Set::Self::Now do
  it "should have a date" do
    render_card(:raw, :name=>'*now').match(/\w+day, \w+ \d+, \d{4}/ ).should_not be_nil
  end
end
