# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Type::LayoutType do
  it "should include Html card methods" do
    Card.new( :type=>'Layout' ).clean_html?.should be_false
  end
end
