# -*- encoding : utf-8 -*-
class Card
  class Act < ActiveRecord::Base
    before_save :set_actor
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
    
  private
    def timestamp_attributes_for_create
      super << :acted_at
    end
    
  end
end