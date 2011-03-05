module Cardlib
  module Cacheable
    
    
    def extended_list context = nil
      args={:context => (context ? context.name : self.name), :limit=>''}
      self.item_cards(args).map{|x| x.item_cards(args) }.flatten.map{|y| y.item_names(args) }.flatten
      # this could go on and on..
    end
    
    def contextual_content context = nil
      Slot.new(context).process_content(Slot.new(self)._render_raw)
    end


    
    # FIXME: limit moved here from pointer card.
    # This fixes explosion creating pointer cards, but it
    # should be refactored.    
    #def limit
    #  card = System.setting("#{self.name.tag_name}+*max") or return nil
    #  card.content.strip.to_i
    #end    
    
  end
end
