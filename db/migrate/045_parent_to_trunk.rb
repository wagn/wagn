class ParentToTrunk < ActiveRecord::Migration
  def self.up
    remove_index "cards", :name => "card_parent_id_tag_id_uniq", :unique => true  
    rename_column :cards, :parent_id, :trunk_id
  end

  def self.down
    rename_column :cards, :trunk_id, :parent_id
  end
end
