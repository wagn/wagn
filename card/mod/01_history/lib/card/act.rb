# -*- encoding : utf-8 -*-
class Card
  class Act < ActiveRecord::Base
    before_save :set_actor
    has_many :actions, :foreign_key=>:card_act_id, :inverse_of=> :act, :order => :id, :class_name=> "Card::Action"
    belongs_to :actor, class_name: "Card"
    belongs_to :card    
    def set_actor
      self.actor_id ||= Auth.current_id
    end
    
    def self.delete_actionless
      Card::Act.where(
        "id NOT IN (?)",
        Card::Action.pluck("card_act_id"),
      ).delete_all
    end
    
    def self.find_all_with_actions_on card_ids, args={}
      sql = 'card_actions.card_id IN (:card_ids) AND ( (draft is not true) '
      sql << ( args[:with_drafts] ? 'OR actor_id = :current_user_id)' : ')' )
      vars = {:card_ids => card_ids, :current_user_id=>Card::Auth.current_id }
      Card::Act.joins(:actions).where( sql, vars ).uniq.order(:id).reverse_order
    end
    
    # def actor
    #   Card[ actor_id ]
    # end

    # def card
 #      Card[ card_id ]
 #    end
    
    def action_on card_id
      actions.where( "card_id = #{card.id} and draft is not true" ).first
    end
        
    def elapsed_time
      DateTime.new(acted_at).distance_of_time_in_words_to_now
    end
    
    def relevant_drafts_for card
      drafts.select do |action|
        card.included_card_ids.include?(action.card_id) || (card == action.card)
      end
    end
    
    def relevant_actions_for card, with_drafts=false
      actions.select do |action|
        card.included_card_ids.include?(action.card_id) || (card == action.card)
      end
    end
    
  private
    def timestamp_attributes_for_create
      super << :acted_at
    end
    
  end
end
