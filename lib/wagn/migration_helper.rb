# -*- encoding : utf-8 -*-

module Wagn::MigrationHelper
  def self.card_migration_paths
    Wagn.paths['db/migrate_cards'].to_a
  end
  
  def self.schema_mode type
    new_suffix = type.to_s =~ /card/ ? '_cards' : ''
    original_suffix = ActiveRecord::Base.table_name_suffix
    ActiveRecord::Base.table_name_suffix = new_suffix
    yield
    ActiveRecord::Base.table_name_suffix = original_suffix
  end
  
  def contentedly &block
    Wagn::Cache.reset_global
    Wagn::MigrationHelper.schema_mode '' do
      Account.as_bot do
        ActiveRecord::Base.transaction do
          begin
            yield
          ensure
            Wagn::Cache.reset_global
          end
        end
      end
    end
  end
  
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
