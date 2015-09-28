class Card
  class Query
    class Join
      attr_accessor :from, :to, :from_table, :from_alias, :from_field, :to_table, :to_alias, :to_field, :side, :conditions

      def initialize opts={}
        from_and_to opts
        opts.each do |key, value|
          send "#{key}=", value if value.present?
        end
        @from_field ||= :id
        @to_field   ||= :id

        @conditions = [ [ :cond, SqlCond.new( "#{from_alias}.#{from_field} = #{to_alias}.#{to_field}") ] ]
      end


      def from_and_to opts
        [:from, :to].each do |side|
          object = opts[side]
          case object
          when nil; next
          when Array
            { table: object.shift, alias: object.shift, field: object.shift }
          when Card::Query
            { table: 'cards', alias: object.table_alias }
          when Card::Query::RefClause
            { table: 'card_references', alias: object.table_alias }
          else
            raise "invalid #{side} option: #{object}"
          end.map do |key, value|
            opts[:"#{side}_#{key}"] ||= value
          end
        end
      end

      def side
        @side ||= (from && from.mods[:conj] == 'or') ? 'LEFT' : nil
      end

      def to_sql
        @to_table = "(#{@to_table.sql})" if Card::Query===@to_table
        [ side, 'JOIN', to_table, to_alias, 'ON', on_clause ].compact * ' '
      end

      def on_clause
        @conditions.map do |condition|
          field, val = condition
          val.to_sql field
        end * ' AND '
      end

    end
  end
end

