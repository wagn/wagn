class CleanCardTable < ActiveRecord::Migration
  def self.up  
    remove_column :cards, :value
    remove_column :cards, :sealed
    remove_column :cards, :priority
    remove_column :cards, :plus_sidebar
    remove_column :cards, :writer_id
    remove_column :cards, :writer_type
    remove_column :cards, :old_tag_id
    #remove_column :cards, :created_by
    #remove_column :cards, :updated_by
  end

  def self.down
  end
end
