require_dependency 'chunks/chunk'
require_dependency 'chunk_manager'

class SplitLinkType < ActiveRecord::Migration
  def up
    add_column :card_references, :present, :integer
    rename_column :card_references, :link_type, :ref_type
    rename_column :card_id, :referer_id
    rename_column :referenced_card_id, :referee_id
    rename_column :referenced_name, :referee_key
  end

  def down
    rename_column :referer_id, :card_id
    rename_column :referee_id, :referenced_card_id
    rename_column :referee_key, :referenced_name
    remove_column :card_references, :present
    rename_column :card_references, :ref_type, :link_type
  end
end
