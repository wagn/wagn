class SystemMod < ActiveRecord::Migration
  def self.up
    remove_column :system, :password
    add_column :system, :name, :string, :default=>''
  end

  def self.down
    add_column :system, :password, :string
    remove_column :system, :name
  end
end
