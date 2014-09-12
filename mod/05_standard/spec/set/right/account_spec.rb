# -*- encoding : utf-8 -*-

describe Card::Set::Right::Account do
  
  describe '#create' do
    context "valid user" do
      #note - much of this is tested in account_request_spec
      before do
        Card::Auth.as_bot do
          @user_card = Card.create! :name=>'TmpUser', :type_id=>Card::UserID, '+*account'=>{ 
            '+*email'=>'tmpuser@wagn.org', '+*password'=>'tmp_pass'
          }
        end
      
      end
      
      it 'should create an authenticable password' do
        Card::Auth.password_authenticated?( @user_card.account, 'tmp_pass').should be_true
      end
    end
    
    it "should check accountability of 'accounted' card" do
      @unaccountable = Card.create :name=>'BasicUnaccountable', '+*account'=>{ '+*email'=>'tmpuser@wagn.org', '+*password'=>'tmp_pass' }
      @unaccountable.errors['+*account'].first.should == 'not allowed on this card'
    end
    
    it "should require email" do
      @no_email = Card.create :name=>'TmpUser', :type_id=>Card::UserID, '+*account'=>{ '+*password'=>'tmp_pass' }
      @no_email.errors['+*account'].first.should =~ /email required/
    end
  end
  
  describe '#send_account_confirmation_email' do
    before do
      @email = 'joe@user.com'
      @account = Card::Auth[@email].account
      ActionMailer::Base.deliveries = []
      @account.send_account_confirmation_email
      @mail = ActionMailer::Base.deliveries.last
    end

    it 'has correct address' do
      expect( @mail.to ).to eq([@email])
    end

    it 'contains deck title' do
      expect( @mail.body.raw_source ).to match(Card.setting( :title ))
    end

    it 'contains link to verify account' do
      expect( @mail.body.raw_source ).to include("/update/#{@account.left.cardname.url_key}?token=#{@account.token}")
    end

    it 'contains expiry days' do
      expect(@mail.body.raw_source).to include("(link will remain valid for #{Wagn.config.token_expiry / 1.day } days)")
    end
  end

  describe '#send_reset_password_token' do
    before do
      @email = 'joe@user.com'
      @account = Card::Auth[@email].account
      ActionMailer::Base.deliveries = []
      @account.send_reset_password_token
      @mail = ActionMailer::Base.deliveries.last
    end

    it 'contains deck title' do
      expect( @mail.body.raw_source ).to match(Card.setting( :title ))
    end

    it 'contains password resset link' do
      expect( @mail.body.raw_source ).to include("/update/#{@account.cardname.url_key}?reset_token=#{@account.token_card.refresh(true).content}")
    end

    it 'contains expiry days' do
      expect(@mail.body.raw_source).to include("(link will remain valid for #{Wagn.config.token_expiry / 1.day } days)")
    end
  end
  
  
  
  
  describe '#update_attributes' do
    before :each do
      @user_card = Card::Auth[ 'joe@user.com' ]
    end

    it 'should reset password' do
      @user_card.account.password_card.update_attributes!(:content => 'new password')
      assert_equal @user_card.id, Card::Auth.authenticate('joe@user.com', 'new password')
    end
  
    it 'should not rehash password when updating email' do
      @user_card.account.email_card.update_attributes!(:content => 'joe2@user.com')
      assert_equal @user_card.id, Card::Auth.authenticate('joe2@user.com', 'joe_pass')
    end
  end
  
  
  describe '#reset_password' do
    before :each do
      @email = 'joe@user.com'
      @account = Card::Auth[@email].account
      @account.send_reset_password_token
      @token = @account.token
      Card::Env.params[:reset_token] = @token
      Card::Auth.current_id = Card::AnonymousID
    end

    it 'should authenticate with correct token and delete token card' do
      Card::Auth.current_id.should == Card::AnonymousID
      @account.save.should == true
      Card::Auth.current_id.should == @account.left_id
      @account = @account.refresh force=true
      @account.fetch(:trait => :token).should be_nil
      @account.save.should == false
    end
  
    it 'should not work if token is expired' do
      @account.token_card.update_column :updated_at, 3.days.ago.strftime("%F %T")
      @account.token_card.expire
      
      result = @account.save
      result.should == true                 # successfully completes save
      @account.token.should_not == @token   # token gets updated
      success = Card::Env.params[:success]
      success[:message].should =~ /expired/ # user notified of expired token
    end
    
    it 'should not work if token is wrong' do
      Card::Env.params[:reset_token] = @token + 'xxx'
      @account.save
      @account.errors[:abort].first.should =~ /incorrect_token/
    end  
    
  end
  
end

