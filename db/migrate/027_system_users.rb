require_dependency 'db/card_creator.rb'

class SystemUsers < ActiveRecord::Migration
  def self.up
    unless select_one( %{ select * from users where login='admin' })
      # FIXME: not finished
      admin = MUser.new( 
        :login => 'wagnbot',
        :password => 'h88ze',
        :password_confirmation => 'h88ze',
        :invited_by=>1, 
        :activated_at=>nil,
        :revised_at => Time.now(),
        :email => 'hoozebot@grasscommons.org',
        :created_by=>1
      )
    end
    
    unless select_one( %{ select * from users where login='hoozebot' })
      # FIXME: not finished
      wagn_bot = MUser.new( 
        :login => 'admin',
        :password => 'w8gn8t0r',
        :password_confirmation => 'w8gn8t0r',
        :invited_by=>1, 
        :activated_at=>nil,
        :revised_at => Time.now(),
        :email => 'webmaster@grasscommons.org',
        :created_by=>1
      )
    end
  end
  
  def self.down
  end
end
