# -*- encoding : utf-8 -*-

class UserModelToCards < ActiveRecord::Migration
  def up
    Account.as_bot do
      #Card['*email+*right+*structure'].delete

      User.all.each do |user|
        acct_card = Card[user.account_id]
        acct_card.email               = user.email
        acct_card.crypted_password    = user.crypted_password
        acct_card.salt                = user.salt
        acct_card.password_reset_code = user.password_reset_code
        acct_card.status              = user.status
        sender = Card[user.invite_sender_id]
        acct_card.invite_sender       = "[[#{sender.cardname}]]" unless sender.nil?
        acct_card.save
      end
    end
  end

  def down
    contentedly do
      
    end
  end
end
