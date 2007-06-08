
class CurrentRevisionViews < ActiveRecord::Migration
  def self.up
    add_index :revisions, 'revised_at'
    add_index :tag_revisions, 'revised_at'
    
    execute %{
      create view current_revisions as
        select distinct on (page_id)
        id, page_id, revised_at, created_by, content 
        from revisions ORDER BY page_id, revised_at DESC
    }
    
    execute %{
      create view current_tag_revisions as
        select distinct on (tag_id)
        id, tag_id, revised_at, created_by, name 
        from tag_revisions ORDER BY tag_id, revised_at DESC
    }
    
  end

  def self.down
    remove_index :revisions, 'revised_at'
    remove_index :tag_revisions, 'revised_at'
    execute "drop view current_revisions"
    execute "drop view current_tag_revisions"
  end
end
