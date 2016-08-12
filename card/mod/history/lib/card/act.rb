# -*- encoding : utf-8 -*-
class Card
  class Act < ActiveRecord::Base
    before_save :set_actor
    has_many :actions,
             -> { order :id },
             foreign_key: :card_act_id,
             inverse_of: :act,
             class_name: "Card::Action"

    belongs_to :actor, class_name: "Card"

    def card
      Card.fetch card_id, look_in_trash: true, skip_modules: true
    end

    class << self
      def delete_cardless
        left_join = "LEFT JOIN cards ON card_acts.card_id = cards.id"
        joins(left_join).where("cards.id IS NULL").delete_all
      end

      def delete_actionless
        joins(
          "LEFT JOIN card_actions ON card_acts.id = card_act_id"
        ).where(
          "card_actions.id is null"
        ).delete_all
      end

      def find_all_with_actions_on card_ids, args={}
        sql = "card_actions.card_id IN (:card_ids) AND ( (draft is not true) "
        sql << (args[:with_drafts] ? "OR actor_id = :current_user_id)" : ")")
        vars = { card_ids: card_ids, current_user_id: Card::Auth.current_id }
        joins(:actions).where(sql, vars).uniq.order(:id).reverse_order
      end

      def all_viewable
        joins = "JOIN card_actions ON card_acts.id = card_act_id " \
                "JOIN cards ON cards.id = card_actions.card_id"
        where = [
          "card_actions.id is not null", # data check. should not be needed
          "cards.id is not null",    # ditto
          "draft is not true",
          Card::Query::SqlStatement.new.permission_conditions("cards")
        ].compact.join " AND "

        joins(joins).where(where).uniq
      end
    end

    def set_actor
      self.actor_id ||= Auth.current_id
    end

    def action_on card_id
      actions.where("card_id = #{card_id} and draft is not true").first
    end

    def main_action
      action_on(card_id) || actions.first
    end

    def elapsed_time
      DateTime.new(acted_at).distance_of_time_in_words_to_now
    end

    def relevant_drafts_for card
      drafts.select do |action|
        card.included_card_ids.include?(action.card_id) ||
          (card.id == action.card_id)
      end
    end

    def relevant_actions_for card
      actions.select do |action|
        (card.id == action.card_id) ||
          card.included_card_ids.include?(action.card_id)
      end
    end

    private

    def timestamp_attributes_for_create
      super << :acted_at
    end
  end
end
