class KillCardUserstamp < ActiveRecord::Migration
  def self.up
    #remove_column :cards, :created_by
    #remove_column :cards, :updated_by
  end

  def self.down
    add_column :cards, :created_by, :integer
    add_column :cards, :updated_by, :integer
  end
end
