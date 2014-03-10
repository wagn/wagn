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
          [ :email, :password, :salt, :status ].each do |field|
            cardname = "#{base.name}+#{Card[:account].name}+#{Card[field].name}"
            content = user.send ( field==:password ? :crypted_password : field )
            Card.create! date_args.merge( :name=>cardname, :content=>content)
          end
        end
      end
    end
  end

  

  def down
    contentedly do
      
    end
  end
end
