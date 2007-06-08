class TagNodeIdNodeTypeUniq < ActiveRecord::Migration
  def self.up
    add_index "tags", ["node_id","node_type"], :name => "tags_node_id_node_type_uniq", :unique => true
  end

  def self.down
  end
end
