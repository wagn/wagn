class AddCardPriority < ActiveRecord::Migration
  def self.up
    add_column :cards, :priority, :integer, :default=>0
    execute %{ update cards set priority = 0 }
    change_column :cards, :priority, :integer, :default=>0, :null=>false
  end

  def self.down
    remove_column :cards, :priority
  end
end
