class Card
  class Query
    class Join
      attr_accessor :from, :to, :from_table, :from_alias, :from_field, :to_table, :to_alias, :to_field, :side

      def initialize opts={}
        from_and_to opts
        opts.each do |key, value|
          send "#{key}=", value if value.present?
        end
        @from_field ||= :id
        @to_field   ||= :id
      end

      def to_sql
        ([ side, 'JOIN', to_table, to_alias ].compact * ' ') + on_condition
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


      def on_condition
        " ON #{from_alias}.#{from_field} = #{to_alias}.#{to_field}"
      end

    end
  end
end

