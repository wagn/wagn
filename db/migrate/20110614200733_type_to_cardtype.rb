class TypeToCardtype < ActiveRecord::Migration
  def self.up
    rename_column :cards, :type, :typecode
  end

  def self.down
    rename_column :cards, :typecode, :type
  end
end
