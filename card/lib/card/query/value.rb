class Card
  class Query
    class Value

      include Clause

      attr_reader :query, :operator, :value

      def initialize rawvalue, query
        @query = query
        @operator, @value = parse_value rawvalue
        canonicalize_operator
      end

      def parse_value rawvalue
        operator =
          case rawvalue
          when Array;     rawvalue.shift
          when String;    '='
          when Integer;   '='
          else raise("Invalid Condition Clause #{rawvalue}.inspect}")
          end
        [operator, rawvalue]
      end

      def canonicalize_operator
        if target = OPERATORS[@operator.to_s]
          @operator = target
        else
          raise "Invalid Operator #{@operator}"
        end
      end


      def sqlize v
        case v
        when Query, SqlCond; v.to_sql
        when Array;    "(" + v.flatten.collect {|x| sqlize(x)}.join(',') + ")"
        else quote(v.to_s)
        end
      end

      def to_sql field
        op,v = @operator, @value
        table = @query.table_alias

        field, v = case field.to_s
          when "cond"
            return "(#{sqlize(v)})"
          when "name"
            ["#{table}.key", [v].flatten.map(&:to_name).map(&:key)]
          when "content"
            ["#{table}.db_content", v]
          else
            ["#{table}.#{safe_sql field}", v]
          end

        v = v[0] if Array===v && v.length==1 && op != 'in'
        if op=='~'
          cxn, v = match_prep(v)
          %{#{field} #{cxn.match(sqlize(v))}}
        else
          "#{field} #{op} #{sqlize(v)}"
        end
      end
    end
  end
end