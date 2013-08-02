# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

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
  
  describe "parties" do
    
    describe User, "Admin User" do
      it "for Wagn Bot" do
        Account.current_id = Card::WagnBotID
        Account.current.parties.sort.should == [Card::WagnBotID, Card::AuthID, Card::AdminID]
      end
      
      it "for Anonymous" do
        Account.current_id = Card::AnonymousID
        Account.current.parties.sort.should == [Card::AnonymousID]
      end

      context 'for Joe User' do
        
        before do
          @joe_user = Account.user
          @joe_user_card = Account.current
        end

        it "should initially have only auth and self " do
          @joe_user_card.parties.should == [Card::AuthID, @joe_user_card.id]
        end
        
        it 'should update when new roles are set' do
          roles_card = @joe_user_card.fetch :trait=>:roles, :new=>{}
          #note this is really testing functionality that's used in CardController#update_account
          r1 = Card['r1']
          Account.as_bot { roles_card.items = [ r1.id ] }
          @joe_user_card.refresh.parties.should == [ Card::AuthID, r1.id, @joe_user_card.id ]
        end

      end
    end
  end
  
  describe 'among?' do
    it 'should be true for self' do
      Account.current.among?([Account.current_id]).should be_true
    end
  end
  
end
