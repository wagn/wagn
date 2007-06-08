class AddDynamicflagToNodetypes < ActiveRecord::Migration
  def self.up
    add_column :nodetypes, :system, :boolean
  end

  def self.down
    remove_column :nodetypes, :system
  end
end
