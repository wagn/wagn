class NodeAndDataTypes < ActiveRecord::Migration
  def self.up
    create_table :nodetypes do |t|
      t.column :class_name, :string
    end
    
    create_table :datatypes do |t|
    end
    
  end

  def self.down
    drop_table :nodetypes
    drop_table :datatypes
  end
end
