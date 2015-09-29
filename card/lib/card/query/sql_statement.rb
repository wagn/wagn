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
        ['SELECT DISTINCT',
          @fields, 'FROM', @tables, @joins,
          @where, @group,
          @order, @limit_and_offset
        ].compact * ' '
      end

      def tables
        "cards #{@query.table_alias}"
      end

      def fields
        table = @query.table_alias
        field = @mods[:return]
        field = field.blank? ? :card : field.to_sym

        field =
          case field
          when :raw;     "#{table}.*"
          when :card;    "#{table}.name"
          when :count;   "coalesce(count(*),0) as count"
          when :content; "#{table}.db_content"
          else
            if ATTRIBUTES[field.to_sym]==:basic
              "#{table}.#{field}"
            else
              safe_sql field
            end
          end

        [ field, @mods[:sort_join_field] ].compact * ', '
      end

      def joins query
        [ join_clause(query),
          query.subqueries.map { |sq| joins sq }
        ].flatten * "\n"
      end

      def join_clause query
        query.joins.map do |join|
          j =  join.to_sql
          j += " AND #{standard_conditions query}" if join.to_table == 'cards'
          j
        end
      end

      def where
        conditions = [ query_conditions(@query), standard_conditions(@query) ]
        conditions = conditions.reject( &:blank? ).join " AND \n    "
        where = "WHERE #{conditions}" unless conditions.blank?
      end

      def query_conditions query
        cond_list = basic_conditions query
        cond_list +=
          query.subqueries.map do |query|
            query_conditions query
          end
        cond_list.reject! &:blank?

        if cond_list.size > 1
          "(#{ cond_list.join " #{ query.current_conjunction.upcase }\n" })"
        else
          cond_list.join
        end
      end

      def basic_conditions query
        query.conditions.map do |condition|
          field, val = condition
          val.to_sql field
        end
      end

      def standard_conditions query
        [trash_condition(query), permission_conditions(query)].compact * ' AND '
      end

      def trash_condition query
        "#{query.table_alias}.trash is false"
      end

      def permission_conditions query
        unless Auth.always_ok?
          read_rules = Auth.as_card.read_rules
          read_rule_list = read_rules.nil? ? 1 : read_rules.join(',')
          "#{query.table_alias}.read_rule_id IN (#{ read_rule_list })"
        end
      end

      def group
        group = @mods[:group]
        "GROUP BY #{ safe_sql group }" if group.present?
      end

      def limit_and_offset
        full_syntax do
          limit, offset = @mods[:limit], @mods[:offset]
          if limit.to_i > 0
            string =  "LIMIT  #{ limit.to_i  }"
            string += "OFFSET #{ offset.to_i }" if offset.present?
            string
          end
        end
      end

      def full_syntax
        unless @query.superquery or @mods[:return]=='count'
          yield
        end
      end

      def order
        full_syntax do
          order_key ||= @mods[:sort].blank? ? "update" : @mods[:sort]

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
        order_field = case key
          when "id";              "#{table}.id"
          when "update";          "#{table}.updated_at"
          when "create";          "#{table}.created_at"
          when /^(name|alpha)$/;  "LOWER( #{table}.key )"
          when 'content';         "#{table}.db_content"
          when "relevance";       "#{table}.updated_at" #deprecated
          else
            safe_sql(key)
          end
        order_field = "CAST(#{order_field} AS #{cast_type(safe_sql as)})" if as
        @fields += ", #{order_field}"
        "#{order_field} #{dir}"

      end

      def safe_sql(txt)
        txt = txt.to_s
        txt.match( /[^\w\*\(\)\s\.\,]/ ) ? raise( "WQL contains disallowed characters: #{txt}" ) : txt
      end

      def cast_type(type)
        cxn ||= ActiveRecord::Base.connection
        (val = cxn.cast_types[type.to_sym]) ? val[:name] : safe_sql(type)
      end

    end

    class SqlCond < String
      def to_sql *args
        self
      end
    end
  end
end