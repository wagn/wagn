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
    end

    class PostgreSQLAdapter
      def quote_interval(string)
        "interval '#{string}'"
      end
      
      def match(string)
        "~* #{string}"
      end
    end
    
    class MysqlAdapter
      def quote_interval(string)
        "interval #{string}"
      end
      
      def match(string)
        "REGEXP #{string}"
      end
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
