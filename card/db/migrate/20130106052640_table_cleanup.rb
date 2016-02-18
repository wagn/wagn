# -*- encoding : utf-8 -*-
class TableCleanup < ActiveRecord::Migration
  def up
    drop_table :cardtypes
    drop_table :multihost_mappings
    drop_table :roles
    drop_table :roles_users

    remove_column :cards, :typecode
    remove_column :cards, :extension_id
    remove_column :cards, :extension_type
    remove_column :cards, :created_by
    remove_column :cards, :updated_by
    remove_column :cards, :indexed_name
    remove_column :cards, :indexed_content

    remove_column :card_revisions, :created_by

    remove_column :card_references, :created_at
    remove_column :card_references, :updated_at
  end

  def down
  end
end
