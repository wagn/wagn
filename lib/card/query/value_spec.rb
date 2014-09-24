class Card::Query
  class ValueSpec < Spec
    def initialize spec, cardspec
      @cardspec = cardspec

      # bare value shortcut
      @spec = case spec
        when ValueSpec; spec.instance_variable_get('@spec')  # FIXME what a hack (what's this for?)
        when Array;     spec
        when String;    ['=', spec]
        when Integer;   ['=', spec]
        else raise("Invalid Condition Spec #{spec.inspect}")
      end

      # operator aliases
      @spec[0] = @spec[0].to_s
      if target = OPERATORS[@spec[0]]
        @spec[0] = target
      end

      # check valid operator
      raise("Invalid Operator #{@spec[0]}") unless OPERATORS.has_key?(@spec[0])

      # handle IN  #FIXME -- shouldn't this handle "not in", too?
      if @spec[0]=='in' and !@spec[1].is_a?(CardSpec) and !@spec[1].is_a?(RefSpec)
        @spec = [@spec[0], @spec[1..-1]]
      end
    end

    def op
      @spec[0]
    end

    def sqlize(v)
      case v
        when CardSpec, RefSpec, SqlCond; v.to_sql
        when Array;    "(" + v.flatten.collect {|x| sqlize(x)}.join(',') + ")"
        else quote(v.to_s)
      end
    end

    def to_sql field
      op,v = @spec
      #warn "to_sql(#{field}), #{op}, #{v}, #{@cardspec.inspect}"
      v=@cardspec.selfname if v=='_self'
      table = @cardspec.table_alias

      #warn "to_sql #{field}, #{v} (#{op})"
      field, v = case field
        when "cond";     return "(#{sqlize(v)})"
        when "name";     ["#{table}.key",      [v].flatten.map(&:to_name).map(&:key)]
        when "content";  ["#{table}.db_content", v]
        else;            ["#{table}.#{safe_sql(field)}", v]
        end

      v = v[0] if Array===v && v.length==1
      if op=='~'
        cxn, v = match_prep(v,@cardspec)
        %{#{field} #{cxn.match(sqlize(v))}}
      else
        "#{field} #{op} #{sqlize(v)}"
      end
    end
  end
end