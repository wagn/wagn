module Cardlib
  module Cacheable
    
    def extended_list context = nil
      context = (context ? context.name : self.name)
      args={ :limit=>'' }
      self.item_cards(args.merge(:context=>context)).map do |x| 
        x.item_cards(args) 
      end.flatten.map do |x| 
        x.item_cards(args)
      end.flatten.map do |y|
        y.item_names(args)
      end.flatten
      # this could go on and on..
    end
    
    def contextual_content context = nil
      RichHtmlRenderer.new(context).process_content(Renderer.new(self)._render_raw)
    end
  end
end
