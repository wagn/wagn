# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Right::Account do
  
  before :each do
    @user_card = Account[ 'joe@user.com' ]
  end
  
  describe '#update_attributes' do

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

