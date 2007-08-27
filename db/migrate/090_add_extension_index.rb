class AddExtensionIndex < ActiveRecord::Migration
  def self.up
    add_index "cards", ["extension_type", "extension_id"], :name=>"cards_extension_index"
  end

  def self.down
    remove_index "cards", :name=>"cards_extension_index"
  end
end
