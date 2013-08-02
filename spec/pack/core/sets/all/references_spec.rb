# -*- encoding : utf-8 -*-
require 'wagn/pack_spec_helper'

describe Card::Set::All::References do
  # should this one work?  I think not ...
  it "should replace references should work on inclusions inside links" do
    pending "I think this one doesn't need to work delete?"
    card = Card.create!(:name=>"test", :content=>"[[test{{test}}]]"  )
    assert_equal "[[test{{best}}]]", card.replace_references( "test", "best" )
  end

  it "should replace references should work on inclusions inside links" do
    card = Card.create!(:name=>"test", :content=>"[[test_card|test{{test}}]]"  )
    assert_equal "[[test_card|test{{best}}]]", card.replace_references("test", "best" )
  end
end
