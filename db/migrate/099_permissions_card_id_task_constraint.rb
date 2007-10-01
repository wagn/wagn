class PermissionsCardIdTaskConstraint < ActiveRecord::Migration
  def self.up  
    add_unique_index :permissions, :task, :card_id
  end

  def self.down
  end
end
