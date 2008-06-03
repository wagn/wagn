class AddPermissionIndex < ActiveRecord::Migration
  def self.up
    add_index "permissions", ["task"], :name => "permissions_task_index"
    add_index "cards", ["reader_id"], :name=>"card_reader_id_index"
    add_index "cards", ["reader_type"], :name=>"card_reader_type_index"
    add_index "cards", ["type"], :name=>"card_type_index"
  end

  def self.down
  end
end
