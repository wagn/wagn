class CardIndices < ActiveRecord::Migration
  def self.up
    add_index :cards, :tag_id
    add_index :cards, :trunk_id
  end

  def self.down
  end
end 
