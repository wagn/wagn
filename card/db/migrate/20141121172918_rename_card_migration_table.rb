class RenameCardMigrationTable < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.table_exists? :schema_migrations_cards
      rename_table :schema_migrations_cards, :schema_migrations_core_cards
    else
      create_table "schema_migrations_core_cards", id: false, force: true do |t|
        t.string "version", null: false
      end
    end
  end

  def self.down
    rename_table :schema_migrations_core_cards, :schema_migrations_cards
  end
end
