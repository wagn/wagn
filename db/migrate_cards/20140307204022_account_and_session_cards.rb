# -*- encoding : utf-8 -*-

class AccountAndSessionCards < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      [ :session, :encrypted_password, :password_token ].each do |codename|
        Card.create! :name=>"*#{codename}", :codename=>codename
        [:create, :read, :update, :delete].each do |permission|
          Card.create!( 
            :name=>"*#{codename}+#{Card[:right].name}+#{Card[permission].name}",
            :content=>"[[#{Card[:administrator]}]]"
          )
        end
      end
    end
  end

  def down
    contentedly do
      
    end
  end
end
