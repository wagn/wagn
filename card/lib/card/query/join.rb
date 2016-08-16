class Card
  class Query
    class Join
      attr_accessor :conditions, :side,
                    :from, :to,
                    :from_table, :to_table,
                    :from_alias, :to_alias,
                    :from_field, :to_field,
                    :superjoin, :subjoins

      def initialize opts={}
        from_and_to opts
        opts.each do |key, value|
          send "#{key}=", value if value.present?
        end
        @from_field ||= :id
        @to_field   ||= :id
        @conditions = []
        @subjoins = []
        if @from.is_a? Join
          @superjoin = @from
          @superjoin.subjoins << self
        end
        self
      end

      def from_and_to opts
        [:from, :to].each do |side|
          object = opts[side]
          case object
          when nil then next
          when Array
            { table: object.shift, alias: object.shift, field: object.shift }
          when Card::Query
            { table: "cards", alias: object.table_alias }
          when Card::Query::Reference
            { table: "card_references", alias: object.table_alias }
          when Card::Query::Join
            raise "to: cannot be Join" if side == :to
            { table: object.to_table, alias: object.to_alias }
          else
            raise "invalid #{side} option: #{object}"
          end.map do |key, value|
            opts[:"#{side}_#{key}"] ||= value
          end
        end
      end

      def side
        if !@side.nil?
          @side
        else
          in_or = from && from.is_a?(Card::Query) && from.mods[:conj] == "or"
          @side = in_or ? "LEFT" : nil
        end
      end

      def left?
        side == "LEFT"
      end

      def in_left?
        if !@in_left.nil?
          @in_left
        else
          @in_left = left? || (!@superjoin.nil? && @superjoin.in_left?)
        end
      end
    end
  end
end
