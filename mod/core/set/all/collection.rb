
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

def contextual_content context_card, format_args={}
  format_args[:not_current] = true
  context_card.format(format_args).process_content(
    self.format(:not_current=>true)._render_raw
  )
end

format do
  
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