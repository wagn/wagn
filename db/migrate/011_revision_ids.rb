class RevisionIds < ActiveRecord::Migration
  def self.up
    add_column :tags, 'current_revision_id', :integer
    add_column :pages, 'current_revision_id', :integer
    add_foreign_key :tags, 'current_revision_id', :tag_revisions
    add_foreign_key :pages, 'current_revision_id', :revisions
    
    execute("update pages set current_revision_id=(select id from revisions where page_id=pages.id order by id DESC limit 1)")
    execute("update tags set current_revision_id=(select id from tag_revisions where tag_id=tags.id order by id DESC limit 1)")
    
  end

  def self.down
    remove_column :tags, 'current_revision_id'
    remove_column :pages, 'current_revision_id'
  end
end
