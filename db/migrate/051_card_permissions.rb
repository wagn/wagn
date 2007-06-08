class CardPermissions < ActiveRecord::Migration
  def self.up
    add_column :cards, :role_id, :integer
    add_column :cards, :private, :boolean, :default=>false
    
    #TODO: remove sealed
  end

  def self.down
    remove_column :cards, :role_id
    remove_column :cards, :private
  end
end
