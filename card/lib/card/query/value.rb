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
        case rawvalue
        when String, Integer then ["=", rawvalue]
        when Array           then [rawvalue[0], rawvalue[1..-1]]
        else raise("Invalid Condition Clause #{rawvalue}.inspect}")
        end
      end

      def canonicalize_operator
        if target = OPERATORS[@operator.to_s]
          @operator = target
        else
          raise BadQuery, "Invalid Operator #{@operator}"
        end
      end

      def sqlize v
        case v
        when Query then  v.to_sql
        when Array then  "(" + v.flatten.map { |x| sqlize(x) }.join(",") + ")"
        else quote(v.to_s)
        end
      end

      def to_sql field
        op = @operator
        v = @value
        table = @query.table_alias

        field, v = case field.to_s
                   when "name"
                     ["#{table}.key", [v].flatten.map(&:to_name).map(&:key)]
                   when "content"
                     ["#{table}.db_content", v]
                   else
                     ["#{table}.#{safe_sql field}", v]
          end

        v = v[0] if Array === v && v.length == 1 && op != "in"
        if op == "~"
          cxn, v = match_prep(v)
          %(#{field} #{cxn.match(sqlize(v))})
        else
          "#{field} #{op} #{sqlize(v)}"
        end
      end
    end
  end
end
