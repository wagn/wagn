class UserBlock < ActiveRecord::Migration
  def self.up
    add_column :users, :blocked, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :users, :blocked
  end
end
