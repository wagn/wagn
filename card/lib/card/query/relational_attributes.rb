class Card
  class Query
    module RelationalAttributes

      def type val
        restrict :type_id, val
      end

      def part val
        right_val = val.is_a?(Integer) ? val : val.clone
        any(left: val, right: right_val)
      end

      def left val
        restrict :left_id, val
      end

      def right val
        restrict :right_id, val
      end

      def editor_of val
        act_join = Join.new(
          from: self,
          to: ["card_acts", "a#{table_id true}", "actor_id"]
        )
        joins << act_join
        action_join = Join.new(
          from: act_join,
          to: ["card_actions", "an#{table_id true}", "card_act_id"],
          superjoin: act_join
        )
        join_cards val, from: action_join, from_field: "card_id"
      end

      def edited_by val
        action_join = Join.new(
          from: self,
          to: ["card_actions", "an#{table_id true}", "card_id"]
        )
        joins << action_join
        act_join = Join.new(
          from: action_join,
          from_field: "card_act_id",
          to: ["card_acts", "a#{table_id true}"]
        )
        join_cards val, from: act_join, from_field: "actor_id"
      end

      def last_editor_of val
        join_cards val, to_field: "updater_id"
      end

      def last_edited_by val
        restrict :updater_id, val
      end

      def creator_of val
        join_cards val, to_field: "creator_id"
      end

      def created_by val
        restrict :creator_id, val
      end

      def member_of val
        interpret right_plus: [RolesID, refer_to: val]
      end

      def member val
        interpret referred_to_by: { left: val, right: RolesID }
      end

      # ~~~~~~ PLUS RELATIONAL

      def left_plus val
        junction val, :left, :right_id
      end

      def right_plus val
        junction val, :right, :left_id
      end

      def plus val
        any(left_plus: val, right_plus: val.deep_clone)
      end

      def junction val, side, to_field
        part_clause, junction_clause = val.is_a?(Array) ? val : [val, {}]
        junction_val = clause_to_hash(junction_clause).merge side => part_clause
        join_cards junction_val, to_field: to_field
      end
    end
  end
end
