# -*- encoding : utf-8 -*-

class AccountRequestsToSignups < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      #d
      newname = 'Sign up'
      newname = '*signup' if Card.exists? name
      
      #get old codename and name out of the way
      old_signup = Card[:signup]
      old_signup_name = old_signup.name
      old_signup.name = "#{newname} - old"
      old_signup.codename = nil
      old_signup.save!

      Card::Codename.reset_cache
      
      # rename Account Request to "Sign up"
      new_signup = Card[:account_request]
      new_signup.name = newname
      new_signup.update_referencers = true
      new_signup.codename = :signup
      new_signup.save!
      
      # move old "*signup+*thanks" to "Sign up+*type+*thanks"
      thanks = Card[:thanks]
      if signup_thanks = Card["#{old_signup.name}+#{thanks.name}"]
        signup_thanks.name = "#{new_signup.name}+#{Card[:type].name}+#{thanks.name}" 
        signup_thanks.update_referencers = true
        signup_thanks.save!
      end
      
      # get rid of old signup card unless there is other data there (most likely +*subject and +*message)
      unless Card.search(:return=>:id, :left_id=>old_signup.id).first
        old_signup.delete!
      end
      
    end
  end

end
