class TagDatatype < ActiveRecord::Migration
  def self.up
    add_column :tags, 'datatype', :string, :default=>'string'
    add_column :tags, 'label', :boolean, :default=>false
    execute %{ update tags set datatype='string', label='false' } 
    drop_table :datatypes
  end

  def self.down
    remove_column :tags, 'datatype'
    remove_column :tags, 'label'
    create_table :datatypes
  end
end
