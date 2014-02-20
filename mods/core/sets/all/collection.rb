# -*- encoding : utf-8 -*-

module ClassMethods
  
  def search spec
    results = ::Card::Query.new(spec).run
    if block_given? and Array===results
      results.each { |result| yield result }
    end
    results
  end

  def count_by_wql(spec)
    spec.delete(:offset)
    search spec.merge(:return=>'count')
  end
  
end

def item_names(args={})
  Card::Format.new(self)._render_raw.split /[,\n]/
end

def item_cards(args={})  ## FIXME this is inconsistent with item_names
  [self]
end

def item_type
  nil
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

def contextual_content(context_card=nil, format_args={})
  format_args[:not_current] = true
  Card::Format.new(context_card, format_args).process_content(
    Card::Format.new(self, :not_current=>true)._render_raw
  )
end
