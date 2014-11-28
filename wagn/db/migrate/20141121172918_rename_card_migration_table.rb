class RenameCardMigrationTable < ActiveRecord::Migration
  def self.up
    rename_table :schema_migrations_cards, :schema_migrations_core_cards
  end 
  def self.down
    rename_table :schema_migrations_core_cards, :schema_migrations_cards
  end
end
