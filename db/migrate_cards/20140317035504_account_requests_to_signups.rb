# -*- encoding : utf-8 -*-

class AccountRequestsToSignups < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      old_signup = Card[:signup]
      old_signup.name = "#{Card[:signup].name}+config"
      old_signup.codename = nil
      old_signup.save!
      
      #FIXME - *signup+*thanks should go to Signup+*type+*thanks
      
      name = 'Sign Up'
      name = '*signup' if Card.exists? name
      
      new_signup = Card[:signup]
      new_signup.name = name
      new_signup.codename = :signup
      new_signup.save!
    end
  end

end
