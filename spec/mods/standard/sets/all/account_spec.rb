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
        @joe_user_card = Account.current
        @parties = @joe_user_card.parties # note: must be called to test resets
      end

      it "should initially have only auth and self " do
        @parties.should == [Card::AuthID, @joe_user_card.id]
      end
      
      it 'should update when new roles are set' do
        roles_card = @joe_user_card.fetch :trait=>:roles, :new=>{}
        r1 = Card['r1']

        Account.as_bot { roles_card.items = [ r1.id ] }        
        Card['Joe User'].parties.should == @parties            # local cache still has old parties (permission does not change mid-request)        
                                                               
        Wagn::Cache.restore                                    # simulate new request -- clears local cache, where, eg, @parties would still be cached on card
        Account.current_id = Account.current_id                # simulate new request -- current_id assignment clears several class variables
        
        new_parties = [ Card::AuthID, r1.id, @joe_user_card.id ]
        Card['Joe User'].parties.should == new_parties         # @parties regenerated, now with correct values
        Account.current. parties.should == new_parties
        
        # @joe_user_card.refresh(force=true).parties.should == new_parties   # should work, but now superfluous?
      end
    end
    
  end
  
  describe 'among?' do
    it 'should be true for self' do
      Account.current.among?([Account.current_id]).should be_true
    end
  end
  
end
