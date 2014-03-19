# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::Trash do
  
  it "certain 'all rules' should be indestructable" do
    Card::Auth.as_bot do
      name = '*all+*default'
      card = Card[name]
      card.delete
      card.errors[:delete].first.should == "#{name} is an indestructible rule"
      Card[name].should be
    end
  end

end
