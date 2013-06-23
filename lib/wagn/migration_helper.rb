# -*- encoding : utf-8 -*-

module Wagn::MigrationHelper
  def self.card_migration_paths
    rpaths = Rails.application.paths
    rpaths.add 'db/migrate_cards'
    rpaths['db/migrate_cards'].to_a
  end
  
  def self.schema_mode type
    suffix = type.to_s =~ /card/ ? '_cards' : ''
    ActiveRecord::Base.table_name_suffix = suffix
    yield
    ActiveRecord::Base.table_name_suffix = ''
  end
  
  def contentedly &block
    Wagn::Cache.reset_global
    ar_suffix = ActiveRecord::Base.table_name_suffix
    ActiveRecord::Base.table_name_suffix = ''
    Account.as_bot do
      ActiveRecord::Base.transaction do
        begin
          yield
        ensure
          Wagn::Cache.reset_global
        end
      end
    end
    ActiveRecord::Base.table_name_suffix = ar_suffix
  end
  
end
