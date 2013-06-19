# -*- encoding : utf-8 -*-

module Wagn::MigrationHelper
  
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
