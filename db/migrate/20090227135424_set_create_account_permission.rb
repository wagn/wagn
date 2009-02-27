class SetCreateAccountPermission < ActiveRecord::Migration
  def self.up
    role = Card['User'].who_can :create
    unless role.tasks.split(',').include?("create_accounts")
      role.tasks = role.tasks + ",create_accounts"
      role.save!
    end
  end

  def self.down
  end
end
