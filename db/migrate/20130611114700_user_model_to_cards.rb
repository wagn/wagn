# -*- encoding : utf-8 -*-

class UserModelToCards < ActiveRecord::Migration
  def up
    Account.as_bot do
      #Card['*email+*right+*structure'].delete

      User.all.each do |user|
        acct_card = Card[user.account_id]
        acct_card.real_email          = user.email
raise "no pw #{user.inspect}" if !user.built_in? && user.crypted_password.blank?
        acct_card.crypted_password    = user.crypted_password
        acct_card.salt                = user.salt
        acct_card.status              = user.status
        acct_card.save
      end
    end
  end

  def down
    contentedly do
      
    end
  end
end
