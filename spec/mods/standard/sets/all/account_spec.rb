# -*- encoding : utf-8 -*-

describe Card::Set::All::Account do
  describe 'accountable?' do
    
    it 'should be false for cards with *accountable rule off' do
      Card['A'].accountable?.should == false
    end

    it 'should be true for cards with *accountable rule on' do
      Card::Auth.as_bot do
        Card.create :name=>'A+*self+*accountable', :content=>'1'
        Card.create :name=>'*account+*right+*create', :content=>'[[Anyone Signed In]]'
      end
      Card['A'].accountable?.should == true
    end
    
  end
  
  describe "parties" do
  
    it "for Wagn Bot" do
      Card::Auth.current_id = Card::WagnBotID
      Card::Auth.current.parties.sort.should == [Card::WagnBotID, Card::AnyoneSignedInID, Card::AdministratorID]
    end
    
    it "for Anonymous" do
      Card::Auth.current_id = Card::AnonymousID
      Card::Auth.current.parties.sort.should == [Card::AnonymousID]
    end

    context 'for Joe User' do
      before do
        @joe_user_card = Card::Auth.current
        @parties = @joe_user_card.parties # note: must be called to test resets
      end

      it "should initially have only auth and self " do
        @parties.should == [Card::AnyoneSignedInID, @joe_user_card.id]
      end
      
      it 'should update when new roles are set' do
        roles_card = @joe_user_card.fetch :trait=>:roles, :new=>{}
        r1 = Card['r1']

        Card::Auth.as_bot { roles_card.items = [ r1.id ] }        
        Card['Joe User'].parties.should == @parties            # local cache still has old parties (permission does not change mid-request)        
                                                               
        Wagn::Cache.restore                                    # simulate new request -- clears local cache, where, eg, @parties would still be cached on card
        Card::Auth.current_id = Card::Auth.current_id                # simulate new request -- current_id assignment clears several class variables
        
        new_parties = [ Card::AnyoneSignedInID, r1.id, @joe_user_card.id ]
        Card['Joe User'].parties.should == new_parties         # @parties regenerated, now with correct values
        Card::Auth.current. parties.should == new_parties
        
        # @joe_user_card.refresh(force=true).parties.should == new_parties   # should work, but now superfluous?
      end
    end
    
  end
  
  describe 'among?' do
    it 'should be true for self' do
      Card::Auth.current.among?([Card::Auth.current_id]).should be_true
    end
  end
  

  describe "'+*email'" do
    it 'should create a card and account card' do
      jadmin = Card['joe admin']
      Card::Auth.current_id = jadmin.id #simulate login to get correct from address
      ja_email = jadmin.account.email

      Card::Env[:params] = { :email => {:subject=>'Hey Joe!', :message=>'Come on in.'} }
      Card.create :name=>'Joe New', :type_id=>Card::UserID, '+*account'=>{ '+*email'=> 'joe@new.com' }

      c = Card['Joe New']
      u = Card::Auth[ 'joe@new.com' ]
      
      c.should == u
      c.type_id.should == Card::UserID
=begin      
      email = ActionMailer::Base.deliveries.last
      email.to.should == ['joe@new.com']
      email.subject.should == 'Hey Joe!'
      email.from.should == [ ja_email ]
=end
    end
  end
  
  context 'updates' do
    before do
      @card = Card['Joe User']
    end
    it "should handle email updates" do
      @card.update_attributes! '+*account'=>{ '+*email'=>'joe@user.co.uk' }
      @card.account.email.should == 'joe@user.co.uk'
    end
  
    it "should let Wagn Bot block accounts" do
      Card::Auth.as_bot do
        @card.account.status_card.update_attributes! :content => 'blocked'
        @card.account.blocked?.should be_true
      end
    end
    
    
    it "should not allow a user to block or unblock himself" do
      expect do
        @card.account.status_card.update_attributes! :content => 'blocked'
      end.to raise_error
      @card.account.blocked?.should be_false
    end
  end
  
  describe "#read_rules" do
    before(:all) do
      @read_rules = Card['joe_user'].read_rules
    end


    it "*all+*read should apply to Joe User" do
      @read_rules.member?(Card.fetch('*all+*read').id).should be_true
    end

    it "9 more should apply to Joe Admin" do
      # includes lots of account rules...
      Card::Auth.as(:joe_admin) do
        ids = Card::Auth.as_card.read_rules
        ids.length.should == @read_rules.size + 9
      end
    end

  end

end
