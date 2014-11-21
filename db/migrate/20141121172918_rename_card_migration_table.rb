class RenameCardMigrationTable < ActiveRecord::Migration
  def self.up
    rename_table :schema_card_migrations, :schema_core_card_migrations
  end 
  def self.down
    rename_table :schema_core_card_migrations, :schema_card_migrations
  end
end
