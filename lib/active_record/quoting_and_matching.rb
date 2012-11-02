module ActiveRecord
  module QuotingAndMatching
    # dummy module to trigger loading code below
  end

  module ConnectionAdapters
    class AbstractAdapter
      def quote_interval(string)
        raise "quote_interval not implemented"
      end

      def match(string)
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
      def quote_interval(string)
        "interval '#{string}'"
      end

      def match(string)
        "~* #{string}"
      end
    end

    module MysqlCommon
      def quote_interval(string)
        "interval #{string}"
      end

      def match(string)
        "REGEXP #{string}"
      end

      def custom_cast_types
        { :string  => { :name=>'char'    },
          :integer => { :name=>'signed'  },
          :text    => { :name=>'char'    },
          :float   => { :name=>'decimal' },
          :binary  => { :name=>'binary'  }  }
      end
    end

    class MysqlAdapter
      include MysqlCommon
    end

    class Mysql2Adapter
      include MysqlCommon
    end

    class SQLiteAdapter
      def quote_interval(string)
        "interval #{string}"
      end

      def match(string)
        "REGEXP #{string}"
      end
    end
  end
end
