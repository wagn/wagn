class CardNameIndex < ActiveRecord::Migration
  def self.up
    add_index :cards, :name
  end

  def self.down
    remove_index :cards, :name
  end
end
