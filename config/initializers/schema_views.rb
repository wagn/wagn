# -*- encoding : utf-8 -*-
module ActiveRecord
  
  #FIXME!!  this is a hacky place to put a hacky bit of code.
  # the following code is already in Rails 4 (see https://github.com/rails/rails/commit/c8792c7b2ea4f5fe7a5610225433ea8dd8d0f83e)
  # it allows manual rollbacks in after_save (eg store events) to reset the object correctly
  
  # really we need to get all this extension code out of config and into lib.  and hopefully we can soon get rid of this code altogether!
  module Transactions
    def with_transaction_returning_status
      status = nil
      self.class.transaction do
        add_to_transaction
        begin
          status = yield
        rescue ActiveRecord::Rollback
          @_start_transaction_state[:level] = (@_start_transaction_state[:level] || 0) - 1
          status = nil
        end

        raise ActiveRecord::Rollback unless status
      end
      status
    end
  end
  
  class SchemaDumper
    def dump(stream)
      header(stream)
      tables(stream)
      #views(stream)
      trailer(stream)
      stream
    end

    private
    def views(stream)
      views = @connection.select_all("SELECT viewname  FROM pg_views WHERE schemaname IN ('$user','public');")
      views.each do |view|
        view( view['viewname'], stream )
      end
    end

    def view(viewname, stream)
      viewinfo = @connection.select_one %{
        SELECT * from pg_views WHERE schemaname IN ('$user','public')
        and viewname='#{viewname}'
      }
      stream.puts <<ENDVIEW
  execute %{
    CREATE VIEW #{viewname} AS
    #{viewinfo['definition']}
  }

ENDVIEW
    end

  end
end
