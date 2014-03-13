# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Codename, "Codename" do

  before do
    @codename = :default
  end

  it "should be sane" do    
    Card[@codename].codename.should == @codename.to_s #would prefer Symbol eventually
    card_id = Card::Codename[@codename]
    card_id.should be_a_kind_of Integer
    Card::Codename[card_id].should == @codename
  end

  it "should make cards indestructable" do
    Account.as_bot do
      card = Card[@codename]
      card.delete
      card.errors[:delete].first.should match 'is a system card'
      Card[@codename].should be
    end
  end
  
end
