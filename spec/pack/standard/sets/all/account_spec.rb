# -*- encoding : utf-8 -*-
require 'wagn/pack_spec_helper'

describe Card::Set::All::Account do
  describe 'accountable?' do
    it 'should be false for existing accounts' do
      Account.current.accountable?.should == false
    end
    
    it 'should be false for cards with *accountable rule off' do
      Card['A'].accountable?.should == false
    end

    it 'should be true for cards with *accountable rule on' do
      Account.as_bot do
        Card.create :name=>'A+*self+*accountable', :content=>'1'
        Card.create :name=>'*account+*right+*create', :content=>'[[Anyone Signed In]]'
      end
      Card['A'].accountable?.should == true
    end
    
  end
end
