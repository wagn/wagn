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

<<<<<<< HEAD
    class PostgreSQLAdapter < AbstractAdapter
=======
    class PostgreSQLAdapter
>>>>>>> 81387a6... Re-adding, but this probably means you need to un-install postgres for mysql to work on 1.9
      def quote_interval(string)
        "interval '#{string}'"
      end
      
      def match(string)
        "~* #{string}"
      end
    end
    
<<<<<<< HEAD
    class MysqlAdapter < AbstractAdapter
=======
    class MysqlAdapter
>>>>>>> 81387a6... Re-adding, but this probably means you need to un-install postgres for mysql to work on 1.9
      def quote_interval(string)
        "interval #{string}"
      end
      
      def match(string)
        "REGEXP #{string}"
      end
    end   

    class Mysql2Adapter
      def quote_interval(string)
        "interval #{string}"
      end
      
      def match(string)
        "REGEXP #{string}"
      end
    end   
    
<<<<<<< HEAD
    class SQLiteAdapter < AbstractAdapter
=======
    class SQLiteAdapter
>>>>>>> 81387a6... Re-adding, but this probably means you need to un-install postgres for mysql to work on 1.9
      def quote_interval(string)
        "interval #{string}"
      end
      
      def match(string)
        "REGEXP #{string}"
      end
    end   
  end
end
