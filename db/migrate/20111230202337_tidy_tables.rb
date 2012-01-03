class TidyTables < ActiveRecord::Migration
  def up
    drop_table :permissions
    drop_table :card_files
    drop_table :card_images
    drop_table :system
    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
    drop_table :db_files
    
    remove_column :cards, :reader_id
    remove_column :cards, :reader_type
    remove_column :cards, :appender_id
    remove_column :cards, :appender_type
    remove_column :cards, :settings
    remove_column :cards, :pattern_keys
    
    remove_column :revisions, :updated_at
    
    remove_index :cards, :name=>"cards_extension_type_id_index"
    remove_index :cards, :name => "cards_name_uniq"
    
    Card.reset_column_information
    Revision.reset_column_information
  end

  def down
    create_table :permissions
    create_table :card_files
    create_table :card_images
    create_table :system
    create_table :open_id_authentication_associations
    create_table :open_id_authentication_nonces
    create_table :db_files
    
    add_column :cards, :reader_id, :integer
    add_column :cards, :reader_type, :string
    add_column :cards, :appender_id, :integer
    add_column :cards, :appender_type, :string
    add_column :cards, :settings, :string
    add_column :cards, :pattern_keys, :string
    
    add_column :revisions, :updated_at, :datetime
    
    add_index :cards, [:name], :name => "cards_name_uniq", :unique => true
    add_index :cards, [:extension_id, :extension_type], :name => "cards_extension_type_id_index", :unique => true
    
    Card.reset_column_information
    Revision.reset_column_information
  end
end
