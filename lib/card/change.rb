# -*- encoding : utf-8 -*-
class Card  
  class Change < ActiveRecord::Base
    belongs_to :action
    
    # replace with enum if we start using rails 4 
    
    
    def field=(value)
      write_attribute(:field, Card::TRACKED_FIELDS.index(value))
    end
    
    def field
      Card::TRACKED_FIELDS[read_attribute(:field)]
    end
  end
end



