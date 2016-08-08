class Card
  class Query
    module Conjunctions
      def all val
        conjoin val, :and
      end
      alias and all

      def any val
        conjoin val, :or
      end
      alias or any
      alias in any

      def conjoin val, conj
        sq = subquery unjoined: true, conj: conj
        unless val.is_a? Array
          val = clause_to_hash(val).map { |key, value| { key => value } }
        end
        val.each do |val_item|
          sq.interpret val_item
        end
      end

      def not val
        notjoin = join_cards val, conditions_on_join: true, side: "LEFT"
        add_condition "#{notjoin.table_alias}.id is null"
      end

      def conjunction val
        return unless [String, Symbol].member? val.class
        CONJUNCTIONS[val.to_sym]
      end
    end
  end
end
