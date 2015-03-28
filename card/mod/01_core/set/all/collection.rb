
module ClassMethods
  def search spec
    query = ::Card::Query.new(spec)
    Card.with_logging :search, :message=>spec, :details=>query.sql.strip do
      results = query.run
      if block_given? and Array===results
        results.each { |result| yield result }
      end
      results
    end
  end

  def count_by_wql(spec)
    spec = spec.clone
    spec.delete(:offset)
    search spec.merge(:return=>'count')
  end

  def find_each(options = {}) 
    #this is a copy from rails (3.2.16) and is needed because this is performed by a relation (ActiveRecord::Relation)
    find_in_batches(options) do |records|
      records.each { |record| yield record }
    end
  end

  def find_in_batches(options = {})
    if block_given?
      super(options) do |records|
        yield(records)
        Card::Cache.reset_global
      end
    else
      super(options)
    end
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

def include_item? item
  key = if Card === item
    item.cardname.key
  else
    item.to_name.key
  end
  item_names.map{|name| name.to_name.key}.member? key
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
    self.format(format_args)._render_raw(view_args), view_args
  )
end

format do
  
  def item_links(args={})
    raw(render_core).split /[,\n]/
  end
  
  def search_params
    @search_params ||= begin
      p = default_search_params.clone
    
      if focal? 
        p[:offset] = params[:offset] if params[:offset]
        p[:limit]  = params[:limit]  if params[:limit]
        p.merge! params[:wql]        if params[:wql]
      end
      p
    end
  end

  def default_search_params # wahh?
    set_default_search_params
  end

  def set_default_search_params overrides={}
    @default_search_params ||= begin
      p = { :default_limit=> 100 }.merge overrides
      set_search_params_variables! p
      p
    end
  end

  def set_search_params_variables! hash
    hash[:vars] = params[:vars] || {}
    params.each do |key,val|
      case key.to_s
      when '_wql'      ;  hash.merge! val
      when /^\_(\w+)$/ ;  hash[:vars][$1.to_sym] = val
      end
    end
  end
end

