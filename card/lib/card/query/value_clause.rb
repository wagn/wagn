class Card::Query
  class ValueClause < Clause
    def initialize clause, cardclause
      @cardclause = cardclause

      # bare value shortcut
      @clause = case clause
        when ValueClause; clause.instance_variable_get('@clause')  # FIXME what a hack (what's this for?)
        when Array;     clause
        when String;    ['=', clause]
        when Integer;   ['=', clause]
        else raise("Invalid Condition Clause #{clause.inspect}")
      end

      # operator aliases
      @clause[0] = @clause[0].to_s
      if target = OPERATORS[@clause[0]]
        @clause[0] = target
      end

      # check valid operator
      raise("Invalid Operator #{@clause[0]}") unless OPERATORS.has_key?(@clause[0])

      # handle IN  #FIXME -- shouldn't this handle "not in", too?
      if @clause[0]=='in' and !@clause[1].is_a?(CardClause) and !@clause[1].is_a?(RefClause)
        @clause = [@clause[0], @clause[1..-1]]
      end
    end

    def op
      @clause[0]
    end

    def sqlize(v)
      case v
        when CardClause, RefClause, SqlCond; v.to_sql
        when Array;    "(" + v.flatten.collect {|x| sqlize(x)}.join(',') + ")"
        else quote(v.to_s)
      end
    end

    def to_sql field
      op,v = @clause
      #warn "to_sql(#{field}), #{op}, #{v}, #{@cardclause.inspect}"
      v=@cardclause.selfname if v=='_self'
      table = @cardclause.table_alias

      #warn "to_sql #{field}, #{v} (#{op})"
      field, v = case field
        when "cond";     return "(#{sqlize(v)})"
        when "name";     ["#{table}.key",      [v].flatten.map(&:to_name).map(&:key)]
        when "content";  ["#{table}.db_content", v]
        else;            ["#{table}.#{safe_sql(field)}", v]
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