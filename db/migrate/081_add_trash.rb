class AddTrash < ActiveRecord::Migration
  def self.up
    add_column :cards, :trash, :boolean, :null=>false, :default=>false
  end

  def self.down
    remove_column :cards, :trash
  end
end
