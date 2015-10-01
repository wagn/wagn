class Card
  class Query
    class SqlStatement
      def initialize query
        @query = query
        @mods = query.mods
      end

      def build
        @fields = fields
        @tables = tables
        @joins  = joins @query
        @where  = where
        @group  = group
        @order  = order
        @limit_and_offset = limit_and_offset
        self
      end

      def to_s
        ["SELECT DISTINCT #{@fields}",
         "FROM #{@tables}",
         @joins,
         @where,
         @group,
         @order,
         @limit_and_offset
        ].compact * "\n"
      end

      def tables
        "cards #{@query.table_alias}"
      end

      def fields
        table = @query.table_alias
        field = @mods[:return]
        field = field.blank? ? :card : field.to_sym
        field = full_field(table, field)
        [field, @mods[:sort_join_field]].compact * ', '
      end

      def full_field table, field
        case field
        when :raw      then "#{table}.*"
        when :card     then "#{table}.name"
        when :content  then "#{table}.db_content"
        when :count
          "coalesce(count( distinct #{table}.id),0) as count"
        else
          if ATTRIBUTES[field.to_sym] == :basic
            "#{table}.#{field}"
          else
            safe_sql field
          end
        end
      end

      def joins query
        [join_on_clause(query, query.joins),
         query.subqueries.map { |sq| joins sq }
        ].flatten * "\n"
      end

      def join_on_clause query, joins
        joins.map do |join|
          [join_clause(query, join),
           'ON',
           on_clause(query, join)
          ].join ' '
        end
      end

      def join_clause query, join
        to_table = join.to_table
        to_table = "(#{to_table.sql})" if to_table.is_a? Card::Query
        table_segment = [to_table, join.to_alias].join ' '
        if query.left_joined? && join == query.joins.first
          deeper_joins = [
            join_on_clause(query, query.joins[1..-1]),
            query.subqueries.map { |sq| joins sq }
          ].flatten
          if !deeper_joins.empty?
            table_segment = "(#{table_segment} #{deeper_joins * ' '})"
          end
        end

        [join.side, 'JOIN', table_segment].compact.join ' '
      end

      def on_clause query, join
        on_conditions = join.conditions
        on_ids = [
          "#{join.from_alias}.#{join.from_field}",
          "#{join.to_alias}.#{join.to_field}"
        ].join ' = '
        on_conditions.unshift on_ids
        if join.to_table == 'cards'
          on_conditions.push(standard_conditions query)
        end
        basic_conditions(on_conditions) * ' AND '
      end

      def where
        conditions = [query_conditions(@query), standard_conditions(@query)]
        conditions = conditions.reject(&:blank?).join "\nAND "
        "WHERE #{conditions}" unless conditions.blank?
      end

      def query_conditions query
        cond_list = basic_conditions query.conditions
        cond_list +=
          query.subqueries.map do |subquery|
            query_conditions subquery
          end
        cond_list.reject!(&:blank?)

        if cond_list.size > 1
          cond_list = cond_list.join "\n#{query.current_conjunction.upcase} "
          "(#{cond_list})"
        else
          cond_list.join
        end
      end

      def basic_conditions conditions
        conditions.map do |condition|
          if condition.is_a? String
            condition
          else
            field, val = condition
            val.to_sql field
          end
        end
      end

      def standard_conditions query
        [trash_condition(query), permission_conditions(query)].compact * ' AND '
      end

      def trash_condition query
        "#{query.table_alias}.trash is false"
      end

      def permission_conditions query
        return if Auth.always_ok?
        read_rules = Auth.as_card.read_rules
        read_rule_list = read_rules.nil? ? 1 : read_rules.join(',')
        "#{query.table_alias}.read_rule_id IN (#{read_rule_list})"
      end

      def group
        group = @mods[:group]
        "GROUP BY #{safe_sql group}" if group.present?
      end

      def limit_and_offset
        full_syntax do
          limit = @mods[:limit]
          offset = @mods[:offset]
          if limit.to_i > 0
            string =  "LIMIT  #{limit.to_i} "
            string += "OFFSET #{offset.to_i} " if offset.present?
            string
          end
        end
      end

      def full_syntax
        return if @query.superquery || @mods[:return]=='count'
        yield
      end

      def order
        full_syntax do
          order_key ||= @mods[:sort].blank? ? 'update' : @mods[:sort]

          order_directives = [order_key].flatten.map do |key|
            dir = if @mods[:dir].blank?
                    DEFAULT_ORDER_DIRS[key.to_sym] || 'asc'
                  else
                    safe_sql @mods[:dir]
                  end
            sort_field key, @mods[:sort_as], dir
          end.join ', '
          "ORDER BY #{order_directives}"
        end
      end

      def sort_field key, as, dir
        table = @query.table_alias
        order_field =
          case key
          when 'id'             then "#{table}.id"
          when 'update'         then "#{table}.updated_at"
          when 'create'         then "#{table}.created_at"
          when /^(name|alpha)$/ then "LOWER( #{table}.key )"
          when 'content'        then "#{table}.db_content"
          when 'relevance'      then "#{table}.updated_at" # deprecated
          else
            safe_sql(key)
          end
        order_field = "CAST(#{order_field} AS #{cast_type(safe_sql as)})" if as
        @fields += ", #{order_field}"
        "#{order_field} #{dir}"

      end

      def safe_sql(txt)
        txt = txt.to_s
        if txt.match(/[^\w\*\(\)\s\.\,]/)
          fail "WQL contains disallowed characters: #{txt}"
        else
          txt
        end
      end

      def cast_type(type)
        cxn ||= ActiveRecord::Base.connection
        (val = cxn.cast_types[type.to_sym]) ? val[:name] : safe_sql(type)
      end
    end
  end
end
