# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::Account do
  describe 'accountable?' do
    
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
  

  describe "#invitation" do
    it 'should create a card, user, and account card' do
      jadmin = Card['joe admin']
      Account.current_id = jadmin.id #simulate login to get correct from address
      ja_email = jadmin.account.email

      Wagn::Env[:params] = { :email => {:subject=>'Hey Joe!', :message=>'Come on in.'} }
      Card.create :name=>'Joe New', :type_id=>Card::UserID, :account_args=>{:email=>'joe@new.com'}

      c = Card['Joe New']
      u = Account[ 'joe@new.com' ]
      
      c.should be
      u.should be
      u.card_id.should == c.id
      c.type_id.should == Card::UserID
      
      email = ActionMailer::Base.deliveries.last
      email.to.should == ['joe@new.com']
      email.subject.should == 'Hey Joe!'
      email.from.should == [ ja_email ]
    end
  end
  
  context 'updates' do
    before do
      @card = Card['Joe User']
    end
    it "should handle email updates" do
      @card.update_attributes :account_args => { :email => 'joe@user.co.uk' }
      @card.account.email.should == 'joe@user.co.uk'
    end
  
    it "should not allow a user to block or unblock himself" do
      expect do
        @card.update_attributes! :account_args => { :blocked => '1' }
      end.to raise_error
      @card.account.blocked?.should be_false
      
      Account.as_bot do
        @card.update_attributes! :account_args => { :blocked => '1' }
        @card.account.blocked?.should be_true
      end
      
    end
  end

end
