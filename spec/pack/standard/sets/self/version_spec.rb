# -*- encoding : utf-8 -*-
require 'wagn/pack_spec_helper'

describe Card::Set::Self::Version do
  it "should have an X.X.X version" do
    (render_card(:raw, :name=>'*version') =~ (/\d\.\d+\.\w+/ )).should be_true
  end
end
