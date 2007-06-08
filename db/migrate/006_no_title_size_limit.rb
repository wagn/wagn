class NoTitleSizeLimit < ActiveRecord::Migration
  def self.up
    execute "alter table wiki_references alter column referenced_name type varchar"
  end

  def self.down
    # who wants to put a dumb limit back on?
  end
end

