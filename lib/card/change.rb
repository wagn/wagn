# -*- encoding : utf-8 -*-
class Card
  class Change < ActiveRecord::Base
    belongs_to :action, :foreign_key=>:card_action_id, :inverse_of=>:changes
    
    # replace with enum if we start using rails 4 
    def field=(value)
      write_attribute(:field, Card::TRACKED_FIELDS.index(value.to_s))
    end
    
    def field
      Card::TRACKED_FIELDS[read_attribute(:field)]
    end
    
    def self.delete_actionless
      Card::Change.where(
        "card_action_id NOT IN (?)",
        Card::Action.pluck("id"),
      ).delete_all
    end
    
    def self.find_by_field(value)
      index = value.is_a?(Integer) ? value : Card::TRACKED_FIELDS.index(value.to_s)
      super(index)
    end
  end
end


