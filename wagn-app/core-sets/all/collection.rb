# -*- encoding : utf-8 -*-
module Model
  
  module ClassMethods
    
    def search(spec)
      ::Wql.new(spec).run
    end

    def count_by_wql(spec)
      spec.delete(:offset)
      search spec.merge(:return=>'count')
    end
    
  end

  def item_names(args={})
    Wagn::Renderer.new(self)._render_raw.split /[,\n]/
  end

  def item_cards(args={})  ## FIXME this is inconsistent with item_names
    [self]
  end

  def extended_list context = nil
    context = (context ? context.cardname : self.cardname)
    args={ :limit=>'' }
    self.item_cards(args.merge(:context=>context)).map do |x|
      x.item_cards(args)
    end.flatten.map do |x|
      x.item_cards(args)
    end.flatten.map do |y|
      y.item_names(args)
    end.flatten
    # this could go on and on.  more elegant to recurse until you don't have a collection
  end

  def contextual_content(context_card=nil, renderer_args={})
    renderer_args[:not_current] = true
    Wagn::Renderer.new(context_card, renderer_args).process_content(
      Wagn::Renderer.new(self, :not_current=>true)._render_raw
    )
  end
end
