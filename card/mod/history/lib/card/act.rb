# -*- encoding : utf-8 -*-
class Card
  # An "act" is a group of recorded {Card::Action actions} on {Card cards}.
  # Together, {Act acts}, {Action actions}, and {Change changes} comprise a
  # comprehensive {Card card} history tracking system.
  #
  # For example, if a given web form submissions updates the contents of
  # three cards, then the submission will result in the recording of three
  # {Action actions}, each of which is tied to one {Act act}.
  #
  # Each act records:
  #
  # - the _actor_id_ (an id associated with the account responsible)
  # - the _card_id_ of the act's primary card
  # - _acted_at_, a timestamp of the action
  # - the _ip_address_ of the actor where applicable.
  #
  class Act < ActiveRecord::Base
    before_save :assign_actor
    has_many :actions, -> { order :id }, foreign_key: :card_act_id,
                                         inverse_of: :act,
                                         class_name: "Card::Action"
    belongs_to :actor, class_name: "Card"

    class << self
      # remove all acts that have no card. (janitorial)
      def delete_cardless
        left_join = "LEFT JOIN cards ON card_acts.card_id = cards.id"
        joins(left_join).where("cards.id IS NULL").delete_all
      end

      # remove all acts that have no action. (janitorial)
      def delete_actionless
        joins(
          "LEFT JOIN card_actions ON card_acts.id = card_act_id"
        ).where(
          "card_actions.id is null"
        ).delete_all
      end

      # all actions on a set of card ids
      # @param card_ids [Array of Integers]
      # @param args [Hash]
      #   with_drafts: [true, false]
      # @return [Array of Actions]
      def find_all_with_actions_on card_ids, args={}
        sql = "card_actions.card_id IN (:card_ids) AND ( (draft is not true) "
        sql << (args[:with_drafts] ? "OR actor_id = :current_user_id)" : ")")
        vars = { card_ids: card_ids, current_user_id: Card::Auth.current_id }
        joins(:actions).where(sql, vars).uniq.order(:id).reverse_order
      end

      # all actions that current user has permission to view
      # @return [Array of Actions]
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

    # the act's primary card
    # @return [Card]
    def card
      res = Card.fetch card_id, look_in_trash: true, skip_modules: true
      return res unless res.type_id.in? [FileID, ImageID]
      binding.pry
      res.include_set_modules
    end

    # act's action on the card in question
    # @param card_id [Integer]
    # @return [Card::Action]
    def action_on card_id
      actions.where("card_id = #{card_id} and draft is not true").first
    end

    # act's action on primary card if it exists. otherwise act's first action
    # @return [Card::Action]
    def main_action
      action_on(card_id) || actions.first
    end

    # time (in words) since act took place
    # @return [String]
    def elapsed_time
      DateTime.new(acted_at).distance_of_time_in_words_to_now
    end

    # act's actions on either the card itself or another card that includes it
    # @param card [Card]
    # @return [Array of Actions]
    def actions_affecting card
      actions.select do |action|
        (card.id == action.card_id) ||
          card.included_card_ids.include?(action.card_id)
      end
    end

    private

    # used by before filter
    def assign_actor
      self.actor_id ||= Auth.current_id
    end

    # used by rails time_ago
    def timestamp_attributes_for_create
      super << :acted_at
    end
  end
end
