class FixMissingKeyCardConstraints < ActiveRecord::Migration
  def self.up
    change_column :cards, :name, :string, :null=>false
    change_column :cards, :key, :string, :null=>false
    add_index :cards, ["name"], :name=>"cards_name_uniq", :unique=>true
  end

  def self.down  
    raise ActiveRecord::IrreversibleMigration
  end
end
