class MigrateTagNames < ActiveRecord::Migration
  def self.up
    Tag.find(:all).each do |tag|
      tag.create_current_revision({
        :revised_at => Time.now(),
        :name => tag.attributes['name'],
        :created_by=>WagBot.instance,
      })
    end
    remove_column :tags, 'name'
  end

  def self.down
    add_column :tags, 'name', :string
    # dunno if this will work...
    execute "update tags set name=(select name from current_tag_revisions where tag_id=tags.id)"
    execute "delete from tag_revisions"
  end
end
