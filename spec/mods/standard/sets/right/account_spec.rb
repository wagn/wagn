# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Right::Account do
  



  describe '#create' do
    before do
      Account.as_bot do
        @user_card = Card.create! :name=>'TmpUser', :type_id=>Card::UserID, '+*account'=>{ 
          '+*email'=>'tmpuser@wagn.org', '+*password'=>'tmp_pass'
        }
      end
      
    end
    it 'should create an authenticable password' do
      Account.password_authenticated?( @user_card.account, 'tmp_pass').should be_true
    end
  end
  
  describe '#update_attributes' do
    before :each do
      @user_card = Account[ 'joe@user.com' ]
    end

    it 'should reset password' do
      @user_card.account.password_card.update_attributes!(:content => 'new password')
      assert_equal @user_card.id, Account.authenticate('joe@user.com', 'new password')
    end
  
    it 'should not rehash password when updating email' do
      @user_card.account.email_card.update_attributes!(:content => 'joe2@user.com')
      assert_equal @user_card.id, Account.authenticate('joe2@user.com', 'joe_pass')
    end
  end
  
  
end

