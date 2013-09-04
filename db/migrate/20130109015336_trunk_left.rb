# -*- encoding : utf-8 -*-
class TrunkLeft < ActiveRecord::Migration
  def up
    rename_column :card_references, :link_type, :ref_type
    rename_column :cards, :tag_id, :right_id
    rename_column :cards, :trunk_id, :left_id
  end

  def down
    rename_column :card_references, :ref_type, :link_type
    rename_column :cards, :right_id, :tag_id
    rename_column :cards, :left_id, :trunk_id
  end
end
