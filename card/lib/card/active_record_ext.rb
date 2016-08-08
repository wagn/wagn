# -*- encoding : utf-8 -*-
module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      def match _string
        raise "match not implemented"
      end

      def cast_types
        native_database_types.merge custom_cast_types
      end

      def custom_cast_types
        {}
      end
    end

    class PostgreSQLAdapter
      def match string
        "~* #{string}"
      end
    end

    module MysqlCommon
      def match string
        "REGEXP #{string}"
      end

      def custom_cast_types
        { string:  { name: "char"    },
          integer: { name: "signed"  },
          text:    { name: "char"    },
          float:   { name: "decimal" },
          binary:  { name: "binary"  }  }
      end
    end

    class MysqlAdapter
      include MysqlCommon
    end

    class Mysql2Adapter
      include MysqlCommon
    end

    class SQLiteAdapter
      def match string
        "REGEXP #{string}"
      end
    end
  end

  module Transactions
    # FIXME!!
    # the following code is already in Rails 4 (see https://github.com/rails/rails/commit/c8792c7b2ea4f5fe7a5610225433ea8dd8d0f83e)
    # it allows manual rollbacks in after_save (eg store events) to reset the object correctly
    #  hopefully we can soon get rid of this code!

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
end
