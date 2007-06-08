load 'app/models/system.rb'

class PermissionRevision < ActiveRecord::Migration
  def self.up
    add_column :cards, :reader_id, :integer
    add_column :cards, :writer_id, :integer
    add_column :cards, :reader_type, :string
    add_column :cards, :writer_type, :string
    #add_column :cards, :reader_is_user, :boolean, :default=>false
    #add_column :cards, :writer_is_user, :boolean, :default=>false
    
    remove_column :cards, :private
    remove_column :cards, :role_id
    
    # TODO: remove sealed
  end

  def self.down
    remove_column :cards, :reader_id
    remove_column :cards, :writer_id
    remove_column :cards, :reader_type
    remove_column :cards, :writer_type

    add_column :cards, :private, :integer, :default=>0
    add_column :cards, :role_id, :integer
    
  end
end
