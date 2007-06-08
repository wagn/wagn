class TagIndices < ActiveRecord::Migration
  def self.up
    add_index "tags", ["node_id"], :name => "tags_node_id_index"
    add_index "tags", ["node_type"], :name => "tags_node_type_index"
  end

  def self.down
  end
end
