class PlusSidebardAndTemplate < ActiveRecord::Migration
  def self.up
    rename_column :cards, :container, :plus_sidebar 
    add_column :tags, :plus_template, :boolean
  end

  def self.down
    rename_column :cards, :plus_sidebar, :container
    remove_column :tags, :plus_template
  end
end
