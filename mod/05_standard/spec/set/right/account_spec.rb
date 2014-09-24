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
        expect(Card::Auth.password_authenticated?( @user_card.account, 'tmp_pass')).to be_truthy
      end
    end
    
    it "should check accountability of 'accounted' card" do
      @unaccountable = Card.create :name=>'BasicUnaccountable', '+*account'=>{ '+*email'=>'tmpuser@wagn.org', '+*password'=>'tmp_pass' }
      expect(@unaccountable.errors['+*account'].first).to eq('not allowed on this card')
    end
    
    it "should require email" do
      @no_email = Card.create :name=>'TmpUser', :type_id=>Card::UserID, '+*account'=>{ '+*password'=>'tmp_pass' }
      expect(@no_email.errors['+*account'].first).to match(/email required/)
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
      expect(Card::Auth.current_id).to eq(Card::AnonymousID)
      expect(@account.save).to eq(true)
      expect(Card::Auth.current_id).to eq(@account.left_id)
      @account = @account.refresh force=true
      expect(@account.fetch(:trait => :token)).to be_nil
      expect(@account.save).to eq(false)
    end
  
    it 'should not work if token is expired' do
      @account.token_card.update_column :updated_at, 3.days.ago.strftime("%F %T")
      @account.token_card.expire
      
      result = @account.save
      expect(result).to eq(true)                 # successfully completes save
      expect(@account.token).not_to eq(@token)   # token gets updated
      success = Card::Env.params[:success]
      expect(success[:message]).to match(/expired/) # user notified of expired token
    end
    
    it 'should not work if token is wrong' do
      Card::Env.params[:reset_token] = @token + 'xxx'
      @account.save
      expect(@account.errors[:abort].first).to match(/incorrect_token/)
    end  
    
  end
  
  
  describe '#send_change_notice' do
    it 'send multipart email' do
      pass
    end
    
    context 'denied access' do
      it 'excludes protected subcards' do
        Card.create(:name=>"A+B+*self+*read", :type=>'Pointer', :content=>"[[u1]]")
        u2 = Card.fetch 'u2+*following'
        u2.add_item "A"
        a = Card.fetch "A"
        a.update_attributes( :content=> "new content", :subcards=>{'+B'=>{:content=>'hidden content'}})
        expect()
      end
      
      it 'sends no email if changes not visible' do
      end
    end
  end
end
