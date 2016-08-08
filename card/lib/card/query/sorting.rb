class Card
  class Query
    module Sorting
      SORT_JOIN_TO_ITEM_MAP = { left: "left_id", right: "right_id" }.freeze

      def sort val
        return nil if @superquery
        sort_field = val[:return] || "db_content"
        item = val.delete(:item) || "left"

        if sort_field == "count"
          sort_by_count val, item
        elsif (join_field = SORT_JOIN_TO_ITEM_MAP[item.to_sym])
          sq = join_cards(val, to_field: join_field,
                               side: "LEFT",
                               conditions_on_join: true)
          @mods[:sort] ||= "#{sq.table_alias}.#{sort_field}"
        else
          raise BadQuery, "sort item: #{item} not yet implemented"
        end
      end

      # EXPERIMENTAL!
      def sort_by_count val, item
        if item == "referred_to"
          @mods[:sort] = "coalesce(count,0)" # needed for postgres
          cs = Query.new(
            return: "coalesce(count(*), 0) as count",
            group: "sort_join_field",
            superquery: self
          )
          subselect = Query.new val.merge(return: "id", superquery: self)
          cs.add_condition "referer_id in (#{subselect.sql})"
          # FIXME: - SQL generated before SQL phase
          cs.joins << Join.new(
            from: cs,
            to: %w(card_references wr referee_id)
          )
          cs.mods[:sort_join_field] = "#{cs.table_alias}.id as sort_join_field"
          # HACK!

          joins << Join.new(
            from: self,
            to: [cs, "srtbl", "sort_join_field"]
          )
        else
          raise BadQuery, "count with item: #{item} not yet implemented"
        end
      end
    end
  end
end
