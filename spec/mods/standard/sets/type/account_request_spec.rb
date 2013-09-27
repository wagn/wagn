# -*- encoding : utf-8 -*-
#require 'rr'

require 'wagn/spec_helper'
Mailer

describe Card::Set::Type::AccountRequest do
  
  before do
    Account.current_id = Card::AnonID
  end
  
  
  context 'request form' do
    before do
      card = Card.new :type_id=>Card::AccountRequestID
      format = Card::Format.new card
      @form = format.render_new
    end
    
    it 'should prompt to signup' do
      Account.as :anonymous do
        @form.match( /Sign Up/ ).should be_true
      end
    end
  end
  

   #FIXME: tests needed : signup without approval
  
  context 'creation' do
    before do
      @card = Card.create :name=>'Joe New', :type_id=>Card::AccountRequestID, :account_args=>{:email=>'joe@new.com'}
    end
    
    
    it 'should create user entry and +*account cards' do
      @card.real?.should be_true
      @card.errors.empty?.should be_true
      @card.type_id.should == Card::AccountRequestID
      
      new_user = Account[ 'joe@new.com' ]
      new_user.should be
      new_user.card_id.should == @card.id
      new_user.pending?.should be_true
      Card['Joe New+*account'].should be
    end
    
    it 'should detect/reject duplicates' do
      dup = Card.create :name=>'Joe Duplicate', :type_id=>Card::AccountRequestID, :account_args=>{ :email=>'joe@new.com' }
      
      dup.real?.should be_false
      dup.errors.empty?.should be_false
      
      Card['Joe Duplicate'].should be_nil
    end
  end
  
  
  context 'signup alerts' do
    before do
      ActionMailer::Base.deliveries = [] #needed?
    end
    
    it 'should be sent when configured' do
      Account.as_bot do
        Card.create! :name=>'*request+*to', :content=>'request@wagn.org'
      end
    
      mock.dont_allow(Mailer).send_account_info
      @card = Card.create :name=>'Joe New', :type_id=>Card::AccountRequestID, :account_args=>{:email=>'joe@new.com'}    
      ActionMailer::Base.deliveries.last.to.should == ['request@wagn.org']
    end
  end
    


  
  
  context 'valid request' do
    before do
      @card = Card.create! :name=>'Big Bad Wolf', :type=>'Account Request', :account_args=>{:email=>'wolf@wagn.org'}
    end

    context 'core view' do
      before do
        @format = Card::Format.new @card
      end
        
      it "should not show invite links to anonymous users" do
        @format.render_core.should_not =~ /invitation-link/
      end
    
      it 'should show invite links to those who can invite' do
        Account.as_bot do
          assert_view_select @format.render_core, 'a[class="invitation-link"]'
        end
      end
    end
    
    context 'approval' do

      
      it 'should convert card to user' do
        Wagn::Env[:params] = { :activate=>true, :email => { :subject=>'subj', :message=>'msg' } }
        Account.as_bot do
          @card.update_attributes :type_id=>Card::UserID
        
          c = @card.refresh
          c.type_id.should == Card::UserID
          c.account.email.should == 'wolf@wagn.org'
          c.account.active?.should be_true
          email = ActionMailer::Base.deliveries.last
          email.to.should == ['wolf@wagn.org']
          email.subject.should == 'subj'
        end
      end
      
    end
  end
  
  context 'auto approve' do
    it 'should happen when configured' do
      Account.as_bot do
        Card['*account+*right+*create'].update_attributes! :content=>'[[Anyone]]'
      end
      
      c = Card.create :name=>'Joe New', :type_id=>Card::AccountRequestID, :account_args=>{:email=>'joe@new.com'}
      c.type_id.should == Card::UserID
      c.account.active?.should be_true
      email = ActionMailer::Base.deliveries.last
      email.to.should == ['joe@new.com']
      email.subject.should =~ /Account info/
    end
  end
  
  
  context 'request validation' do

    it 'should require name' do
      card = Card.create :type_id=>Card::AccountRequestID #, :account=>{ :email=>"bunny@hop.com" } currently no api for this
      #Rails.logger.info "name errors: #{@card.errors.full_messages.inspect}"
      assert card.errors[:name]
    end


   it 'should require a unique name' do
      @card = Card.create :type_code=>'account_request', :name=>"Joe User", :content=>"Let me in!"# :account=>{ :email=>"jamaster@jay.net" }
      assert @card.errors[:name]
    end


    it 'should block user upon delete' do
      Account.as_bot do
        Card.fetch('Ron Request').delete!
      end

      assert_equal nil, Card.fetch('Ron Request')
      assert_equal 'blocked', Account['ron@request.com'].status
    end
  end
end


 