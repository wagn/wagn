class CardTagIdParentIdUniq < ActiveRecord::Migration
  def self.up
    add_index :cards, ["tag_id","parent_id"], :name=>"card_parent_id_tag_id_uniq",:unique=>true
  end

  def self.down
    remove_index :cards,  :name=>"card_parent_id_tag_id_uniq",:unique=>true
  end
end
