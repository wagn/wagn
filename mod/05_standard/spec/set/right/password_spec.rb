# -*- encoding : utf-8 -*-

describe Card::Set::Right::Password do

  before :each do
    @user_card = Card::Auth[ 'joe@user.com' ]
  end
  
  describe '#update_attributes' do

    it 'should encrypt password' do
      @user_card.account.password_card.update_attributes! :content => 'new password'
      expect(@user_card.account.password).not_to eq('new password')
      assert_equal @user_card.id, Card::Auth.authenticate('joe@user.com', 'new password')
    end

    it 'should validate password' do
      password_card = @user_card.account.password_card
      password_card.update_attributes :content => '2b'
      expect(password_card.errors[:password]).not_to be_empty
      
    end
    
    context 'blank password' do
      it "shouldn't change the password" do
        acct = @user_card.account
        original_pw = acct.password
        expect(original_pw.size).to be > 10
        pw_card = acct.password_card
        pw_card.content = ''
        pw_card.save
        expect(original_pw).to eq(pw_card.refresh(force=true).content)
      end
      
      it "shouldn't break email editing" do
        @user_card.account.update_attributes! :subcards=>{'+*password'=>'', '+*email'=>'joe2@user.com'}
        expect(@user_card.account.email).to eq('joe2@user.com')
        expect(@user_card.account.password).not_to be_empty
      end
    end
  end
  
  

end
