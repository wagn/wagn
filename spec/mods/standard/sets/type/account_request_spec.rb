# -*- encoding : utf-8 -*-

require 'wagn/spec_helper'

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
  

   
  context 'signup (without approval)' do
    before do
      Account.as_bot do
        Card.create! :name=>'User+*type+*create', :content=>'[[Anyone]]'
      end
      @request = Card.create! :name=>'Big Bad Wolf', :type=>'Account Request', '+*account'=>{ 
        '+*email'=>'wolf@wagn.org', '+*password'=>'wolf'
      }
      @account = @request.account
      @token = @account.token
    end
    
    it 'should create all the necessary cards' do
      @request.type_id.should == Card::AccountRequestID
      @account.email.should == 'wolf@wagn.org'
      @account.status.should == 'pending'
      @account.salt.should_not == ''
      @account.password.length.should > 10 #encrypted
      @account.token.should_not be_blank
    end
  
    it 'should send email with an appropriate link' do
    end
    
    it 'should create an authenticable token' do
      Account.authenticate_by_token(@token).should == @request.id
    end
  
  
  end


  context 'signup (with approval)' do

  end
  
  
  context 'signup alerts' do
    before do
      ActionMailer::Base.deliveries = [] #needed?
    end
    
    it 'should be sent when configured' do
      Account.as_bot do
        Card.create! :name=>'*request+*to', :content=>'request@wagn.org'
      end
    
      mock.dont_allow(Mailer).send_confirmation_email
      @card = Card.create :name=>'Joe New', :type_id=>Card::AccountRequestID, :account_args=>{:email=>'joe@new.com'}    
      ActionMailer::Base.deliveries.last.to.should == ['request@wagn.org']
    end
  end
    


  
  
  context 'valid request' do
    before do
      @request = Card.create! :name=>'Big Bad Wolf', :type=>'Account Request', '+*account'=>{ 
        '+*email'=>'wolf@wagn.org', '+*password'=>'wolf'
      }
    end

    context 'core view' do
      before do
        @format = Card::Format.new @request
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

  end
end
