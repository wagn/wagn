class AddUserSettings < ActiveRecord::Migration
  def self.up
    add_column :users, :cards_per_page, :integer, :default => 25, :null => false
    add_column :users, :hide_duplicates, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :users, :cards_per_page
    remove_column :users, :hide_duplicates
  end
end
