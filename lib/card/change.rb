# -*- encoding : utf-8 -*-
class Card  
  def last_change_on(field, opts={})
    field_index = Card::TRACKED_FIELDS.index(field.to_s)
    if opts[:before] and opts[:before].kind_of? Card::Action
      Change.joins(:action).where(
          'card_actions.card_id = :card_id AND field = :field AND card_action_id < :action_id', 
                            {:card_id=>id,        :field=>field_index,        :action_id=>opts[:before].id}
        ).order(:id).last
    elsif opts[:not_after] and opts[:not_after].kind_of? Card::Action
      Change.joins(:action).where(
          'card_actions.card_id = :card_id AND field = :field AND card_action_id <= :action_id', 
                            {:card_id=>id,        :field=>field_index,         :action_id=>opts[:not_after].id}
        ).order(:id).last
    else
      Change.joins(:action).where(
          'card_actions.card_id = :card_id AND field = :field', 
                            {:card_id => id,      :field=>field_index}
        ).order(:id).last
    end
  end
  
  class Change < ActiveRecord::Base
    #belongs_to :action, :foreign_key=>:card_action_id
    
    # replace with enum if we start using rails 4 
    
    
    def field=(value)
      write_attribute(:field, Card::TRACKED_FIELDS.index(value.to_s))
    end
    
    def field
      Card::TRACKED_FIELDS[read_attribute(:field)]
    end
    
    def self.find_by_field(value)
      index = value.is_a?(Integer) ? value : Card::TRACKED_FIELDS.index(value.to_s)
      super(index)
    end
  end
end


