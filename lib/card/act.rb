# -*- encoding : utf-8 -*-
class Card
  class Act < ActiveRecord::Base
    before_save :set_actor
    after_save :notify_followers
    has_many :actions, :foreign_key=>:card_act_id, :inverse_of=> :act, :order => :id, :class_name=> "Card::Action"
    belongs_to :actor, class_name: "Card"
    belongs_to :card    
    def set_actor
      self.actor_id = Auth.current_id
    end
    
    # def actor
    #   Card[ actor_id ]
    # end

    def card
      Card[ card_id ]
    end
    
    def action_on card_id
      actions.find_by_card_id(card_id)
    end
    
    def notify_followers
      begin
        return false if Card.record_timestamps==false
        card.card_watchers.each {|w| w.send_change_notice self, card.cardname}
        card.type_watchers.each {|w| w.send_change_notice self, card.type_name}
      
        #@ethn: The rescue part is from the old notify_followers event. Remove it?
      rescue =>e  #this error handling should apply to all extend callback exceptions 
        Airbrake.notify e if Airbrake.configuration.api_key
        Rails.logger.info "\nController exception: #{e.message}"
        Rails.logger.debug "BT: #{e.backtrace*"\n"}"
      end
    end
    
    def elapsed_time
      DateTime.new(acted_at).distance_of_time_in_words_to_now
#      (DateTime.now - acted_at).min
    end
    
    def relevant_actions_for card
  #    if self.card.id == card.id
  #      actions
  #    else
        actions.select do |action|
          card.included_card_ids.include?(action.card_id) || (card == action.card)
        end
  #    end
    end
    
  private
    def timestamp_attributes_for_create
      super << :acted_at
    end
    
  end
end
