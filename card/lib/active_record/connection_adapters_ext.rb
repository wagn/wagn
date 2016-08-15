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
end
