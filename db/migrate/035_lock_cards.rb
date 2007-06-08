class LockCards < ActiveRecord::Migration
  def self.up
    add_column :cards, :sealed, :boolean, :default=>0
  end

  def self.down
    remove_column :cards, :sealed
  end
end
