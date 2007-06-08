require_dependency 'db/card_creator.rb'

class RoleCards < ActiveRecord::Migration
  class << self
    include CardCreator
  end

  def self.up
    create_cardtype_card 'Role'
    
    create_role_card 'Anonymous User', 'anon'
    create_role_card 'Authenticated User', 'auth'
    create_role_card 'Administrative User', 'admin'

    admin_role = MRole.find_by_codename('admin')
    
    admin_role.m_users << %w{ hoozebot admin }.map do |login| 
      MUser.find_by_login login
    end
    
  end

  def self.down
  end
end
