module Wagn::Set::Type::SearchType

  def collection?
    true
  end

  def item_cards params={}
    s = spec(params)
    raise("OH NO.. no limit") unless s[:limit]
    # forces explicit limiting
    # can be 0 or less to force no limit
    #Rails.logger.debug "search item_cards #{params.inspect}"
    Card.search( s )
  end

  def item_names params={}
    ## FIXME - this should just alter the spec to have it return name rather than instantiating all the cards!!
    ## (but need to handle prepend/append)
    #Rails.logger.debug "search item_names #{params.inspect}"
    Card.search(spec(params)).map(&:cardname)
  end

  def item_type
    spec[:type]
  end

  def count params={}
    Card.count_by_wql spec( params )
  end

  def spec params={}
    @spec ||= {}
    @spec[params.to_s] ||= get_spec(params.clone)
  end

  def get_spec params={}
    spec = Session.as_bot do ## why is this a wagn_bot thing?  can't deny search content??
      spec_content = raw_content
      raise("Error in card '#{self.name}':can't run search with empty content") if spec_content.empty?
      JSON.parse( spec_content )
    end
    spec.symbolize_keys!.merge! params.symbolize_keys
    if default_limit = spec.delete(:default_limit) and !spec[:limit]
      spec[:limit] = default_limit
    end
    spec[:context] ||= (cardname.junction? ? cardname.left_name : cardname)
    spec
  end

end
