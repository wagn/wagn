class Card
  class Action
    # methods for administering card actions
    module Admin
      # permanently delete all {Action actions} not associated with a {Card}
      def delete_cardless
        left_join = "LEFT JOIN cards ON card_actions.card_id = cards.id"
        joins(left_join).where("cards.id IS NULL").delete_all
      end

      # permanently delete all {Action actions} not associated with a
      # {Change change}
      def delete_changeless
        joins(
          "LEFT JOIN card_changes "\
          "ON card_changes.card_action_id = card_actions.id"
        ).where(
          "card_changes.id IS NULL"
        ).delete_all
      end

      # permanently delete all {Action actions} associate with non-current
      # {Change changes}
      def delete_old
        Card.find_each(&:delete_old_actions)
        Card::Act.delete_actionless
      end
    end
  end
end
