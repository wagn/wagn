class TypeToCardtype < ActiveRecord::Migration
  def self.up
    rename_column :cards, :type, :cardtype
  end

  def self.down
    rename_column :cards, :cardtype, :type
  end
end
