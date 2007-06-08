class AddTagRevisionRevisedAt < ActiveRecord::Migration
  def self.up
    raise "MAN YOU'RE TOOOOOO FAR BEHIND.  START OVER WITH A NEW DATABASE"
    add_column :tag_revisions, 'revised_at', :datetime, :null => false
    add_column :tag_revisions, 'updated_at', :datetime, :null => false
    remove_column :tag_revisions, 'tag_type'
  end

  def self.down
    add_column :tag_revisions, 'tag_type', :string
    remove_column :tag_revisions, 'revised_at'
    remove_column :tag_revisions, 'updated_at'
  end
end
