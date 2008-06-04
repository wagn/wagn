class ReferenceExpiration < ActiveRecord::Migration
  def self.up 
    add_column :cards, :references_expired, :integer
  end

  def self.down
    remove_column :cards, :references_expired
  end
end
