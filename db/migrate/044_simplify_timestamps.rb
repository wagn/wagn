class SimplifyTimestamps < ActiveRecord::Migration
  def self.up
    begin
      remove_index "revisions", :name => "revisions_revised_at_index"
      remove_index "tag_revisions", :name => "tag_revisions_revised_at_index"
      remove_index "tags", :name => "tags_node_id_index"
      remove_index "tags",  :name => "tags_node_id_node_type_uniq"
      remove_index "tags", :name => "altered_tags_node_type_index"
    rescue 
    end

    remove_column :revisions, :revised_at
    remove_column :tag_revisions, :revised_at
    remove_column :cards, :locked_by
    remove_column :cards, :locked_at
    remove_column :tags, :node_id
    remove_column :tags, :node_type

    add_column :cards, :created_by, :integer
    add_column :cards, :updated_by, :integer
    add_column :tags, :created_by, :integer
    add_column :tags, :updated_by, :integer
  end

  def self.down
    add_column :revisions, :revised_at, :timestamp
    add_column :tag_revisions, :revised_at, :timestamp
    add_column :cards, :locked_by, :integer
    add_column :cards, :locked_at, :timestamp
    add_column :tags, :node_id, :integer
    add_column :tags, :node_type, :string
    remove_column :cards, :created_by
    remove_column :cards, :updated_by
    remove_column :tags, :created_by
    remove_column :tags, :updated_by
  end
end
