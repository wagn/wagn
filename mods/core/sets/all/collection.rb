
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
  format._render_raw.split /[,\n]/
end

def item_cards(args={})  ## FIXME this is inconsistent with item_names
  [self]
end

def item_type
  nil
end

def extended_item_cards context = nil
  context = (context ? context.cardname : self.cardname)
  args={ :limit=>'' }
  items = self.item_cards(args.merge(:context=>context))
  extended_list = []
  already_extended = ::Set.new # avoid loops
  
  while items.size > 0
    item = items.shift
    if already_extended.include? item 
      next
    elsif item.item_cards == [item]  # no further level of items
      extended_list << item
      already_extended << item
    else
      items.unshift(*item.item_cards) # keep items in order
      already_extended << item
    end
  end
  extended_list
end

def extended_item_contents context = nil
  extended_item_cards(context).map(&:item_names).flatten
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

def contextual_content context_card, format_args={}, view_args={}
  context_card.format(format_args).process_content(
    self.format(format_args)._render_raw(view_args)
  )
end
