class AddRevisionIndex < ActiveRecord::Migration
  def self.up
    add_index "revisions", ["created_by"], :name => "revisions_created_by_index"
  end

  def self.down
  end
end
