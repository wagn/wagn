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
  end
  

end
