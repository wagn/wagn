class Card
  class Query
    class Join
      attr_accessor :from, :to, :from_table, :from_alias, :from_field, :to_table, :to_alias, :to_field

      def initialize opts={}
        from_and_to opts
        opts.each do |key, value|
          send "#{key}=", value if value.present?
        end
        @from_field ||= :id
        @to_field   ||= :id
      end

      def to_sql
        ([ side, to_table, to_alias ] * ' ') + on_condition
      end

      def from_and_to opts
        [:from, :to].each do |value|
          object = opts[value]
          case object
          when nil; next
          when Card::Query
            send "#{value}_table=", 'cards'
            send "#{value}_alias=", object.table_alias
          when Card::Query::RefClause
            send "#{value}_table=", 'card_references'
            send "#{value}_alias=", object.table_alias
          end
        end
      end

      def side
        if from && from.mods[:conj] == 'or'
          'LEFT JOIN'
        else
          'JOIN'
        end
      end


      def on_condition
        " ON #{from_alias}.#{from_field} = #{to_alias}.#{to_field}"
      end

    end
  end
end

