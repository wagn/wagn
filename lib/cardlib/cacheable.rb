module Cardlib
  module Cacheable
    
    def extended_list context = nil
      context = (context ? context.name : self.name)
      args={ :limit=>'' }
      self.item_cards(args.merge(:context=>context)).map{|x| x.item_cards(args) }.flatten.map{|y| y.item_names(args) }.flatten
      # this could go on and on..
    end
    
    def contextual_content context = nil
      Slot.new(context).process_content(Slot.new(self)._render_raw)
    end
  end
end
