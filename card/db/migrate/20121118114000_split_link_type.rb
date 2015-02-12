# -*- encoding : utf-8 -*-
class SplitLinkType < ActiveRecord::Migration
  def up
    add_column :card_references, :present, :integer
    rename_column :card_references, :card_id, :referer_id
    rename_column :card_references, :referenced_card_id, :referee_id
    rename_column :card_references, :referenced_name, :referee_key
  end

  def down
    rename_column :card_references, :referer_id, :card_id
    rename_column :card_references, :referee_id, :referenced_card_id
    rename_column :card_references, :referee_key, :referenced_name
    remove_column :card_references, :present
  end
end
