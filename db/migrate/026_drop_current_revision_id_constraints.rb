class DropCurrentRevisionIdConstraints < ActiveRecord::Migration
  def self.up
    execute %{ ALTER TABLE cards DROP CONSTRAINT pages_current_revision_id_fkey }
    drop_foreign_key :tags, :current_revision_id, :tag_revisions
  end

  def self.down
    execute %{ ALTER TABLE cards ADD CONSTRAINT pages_current_revision_id_fkey 
                FOREIGN KEY (current_revision_id) references revisions(id) }
    add_foreign_key :tags, :current_revision_id, :tag_revisions
  end
end
