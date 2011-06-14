module Wagn
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
    
    def contextual_content(context_card=nil, renderer_args={})
      renderer_args[:not_current] = true
      Renderer.new(context_card, renderer_args).process_content(
        Renderer.new(self, :not_current=>true)._render_raw
      )
    end
  end
 end
end
