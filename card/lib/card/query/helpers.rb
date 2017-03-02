class Card
  class Query
    module Helpers
      def restrict id_field, val
        if (id = id_from_val(val))
          interpret id_field => id
        else
          join_cards val, from_field: id_field
        end
      end

      def restrict_reference ref, refjoin
        val = ref.cardquery
        if (id = id_from_val(val))
          add_condition "#{ref.table_alias}.#{ref.outfield} = #{id}"
        else
          join_cards val, from: refjoin, from_field: ref.outfield
        end
      end

      def join_references key, val
        r = Reference.new(key, val, self)
        refjoin = Join.new(from: self, to: r, to_field: r.infield)
        joins << refjoin
        restrict_reference r, refjoin if r.cardquery
        r.conditions.each do |condition|
          refjoin.conditions << "#{r.table_alias}.#{condition}"
        end
      end

      def id_from_val val
        case val
        when Integer then val
        when String  then Card.fetch_id(val)
        end
      end

      def table_alias
        @table_alias ||= begin
          if @unjoined
            @superquery.table_alias
          else
            "c#{table_id}"
          end
        end
      end

      # generates an id used to identify a table variable in the sql statement
      def table_id force=false
        if force
          tick_table_seq!
        else
          @table_id ||= tick_table_seq!
        end
      end

      def tick_table_seq!
        root.table_seq = root.table_seq.to_i + 1
      end

      def join_cards val, opts={}
        conditions_on_join = opts.delete :conditions_on_join
        s = subquery
        join_opts = { from: self, to: s }.merge opts
        card_join = Join.new join_opts
        joins << card_join unless opts[:from].is_a? Join
        s.conditions_on_join = card_join if conditions_on_join
        s.interpret val
        s
      end
    end
  end
end
