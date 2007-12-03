class DropLegacyTables < ActiveRecord::Migration
  def self.up
    drop_table :recent_changes
    drop_table :graveyard
    drop_table :recent_viewings 
    remove_column :tags, :current_revision_id
    drop_table :tag_revisions
    drop_table :tags
    drop_table :wiki_files
  end

  def self.down
  end
end
