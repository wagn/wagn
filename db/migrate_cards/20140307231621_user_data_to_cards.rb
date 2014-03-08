# -*- encoding : utf-8 -*-

class User < ActiveRecord::Base
end

class UserDataToCards < ActiveRecord::Migration
  include Wagn::MigrationHelper
  
  
  
  def up
    contentedly do
      User.all.each do |user|
        base = Card[user.card_id]
        if base and !base.trash
          date_args = { :created_at => user.created_at, :updated_at => user.updated_at }
          acct_name = "#{base.name}+#{Card[:account].name}"
          
          Card.create! date_args.merge( :name=>"#{base.name}+#{Card[:email].name   }", :content=>user.email            )
          Card.create! date_args.merge( :name=>"#{acct_name}+#{Card[:password].name}", :content=>user.crypted_password )
          Card.create! date_args.merge( :name=>"#{acct_name}+#{Card[:salt].name    }", :content=>user.salt             )
          Card.create! date_args.merge( :name=>"#{acct_name}+#{Card[:status].name  }", :content=>user.status           )
        end
      end
    end
  end

  

  def down
    contentedly do
      
    end
  end
end
