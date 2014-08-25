# -*- encoding : utf-8 -*-
require 'byebug'
class Card
  class Action < ActiveRecord::Base
    belongs_to :act, :foreign_key=>:card_act_id
    belongs_to :card
    has_many :changes, :foreign_key=>:card_action_id
    
    # replace with enum if we start using rails 4 
    TYPE = [:create, :update, :delete]
    
    def action_type=(value)
      write_attribute(:action_type, TYPE.index(value))
    end
    
    def action_type
      TYPE[read_attribute(:action_type)]
    end
    
    def set_act
      self.set_act ||= self.acts.last
    end
    
  end
end


