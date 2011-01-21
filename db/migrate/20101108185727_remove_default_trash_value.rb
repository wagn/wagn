class RemoveDefaultTrashValue < ActiveRecord::Migration
  def self.up
    change_column :cards, :trash, :boolean, :default=>nil
  end

  def self.down
    change_column :cards, :trash, :boolean, :default=>false
  end
end
