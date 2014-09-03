# -*- encoding : utf-8 -*-
class Card
  class Act < ActiveRecord::Base
    before_save :set_actor
    after_save :change_notice
    has_many :actions, :order => :id, :foreign_key=>:card_act_id
        
    def set_actor
      self.actor_id = Auth.current_id
    end
    
    def actor
      Card[ actor_id ]
    end

    def card
      Card[ card_id ]
    end
    
    def change_notice
      
    end
    
    # possibility for cross wagn card integration was just created by Anonymous
    #
    # This update included the following changes:
    #
    # created possibility for cross wagn card integration+status
    # created possibility for cross wagn card integration+tags
    # created possibility for cross wagn card integration+issue
    # created possibility for cross wagn card integration+example
    # See the card: http://wagn.org/possibility_for_cross_wagn_card_integration
    #
    # You received this email because you're following "Support Ticket cards".
    # Unfollow to stop receiving these emails.
    
  private
    def timestamp_attributes_for_create
      super << :acted_at
    end
    
  end
end
