# -*- encoding : utf-8 -*-

describe Card::Set::Right::Password do

  before :each do
    @user_card = Card::Auth[ 'joe@user.com' ]
  end
  
  describe '#update_attributes' do

    it 'should encrypt password' do
      @user_card.account.password_card.update_attributes! :content => 'new password'
      @user_card.account.password.should_not == 'new password'
      assert_equal @user_card.id, Card::Auth.authenticate('joe@user.com', 'new password')
    end

    it 'should validate password' do
      password_card = @user_card.account.password_card
      password_card.update_attributes :content => '2b'
      password_card.errors[:password].should_not be_empty
      
    end
    
    context 'blank password' do
      it "shouldn't change the password" do
        acct = @user_card.account
        original_pw = acct.password
        original_pw.size.should > 10
        pw_card = acct.password_card
        pw_card.content = ''
        pw_card.save
        original_pw.should == pw_card.refresh(force=true).content
      end
      
      it "shouldn't break email editing" do
        @user_card.account.update_attributes! '+*password'=>'', '+*email'=>'joe2@user.com'
#        @user_card.account.update_attributes! '+*email'=>'joe2@user.com'
        @user_card.account.email.should == 'joe2@user.com'
      end
    end
  end
  
  

end
