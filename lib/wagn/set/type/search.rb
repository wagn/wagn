module Wagn::Set::Type::Search
  def before_save
    escape_content
  end

  def collection?() true end

  def item_cards(params={})
    s = spec(params)
    raise("OH NO.. no limit") unless s[:limit]
    # forces explicit limiting
    # can be 0 or less to force no limit
    Card.search( s )
  end

  def item_names(params={})
    ## FIXME - this should just alter the spec to have it return name rather than instantiating all the cards!!  
    ## (but need to handle prepend/append)
    Rails.logger.debug "search item_names #{params.inspect}"
    Card.search(spec(params)).map{ |card| card.name}
  end

  def item_type
    spec[:type]
  end

  def count(params={})
    Rails.logger.info "spec(params) = #{spec(params).inspect}.........params = #{params.inspect}"
    Card.count_by_wql( spec(params) )
  end

  def spec(params={})
    @spec ||= {}
    Rails.logger.info "~~~~~params.to_s = #{params.to_s}."#  specs = #{@spec[params.to_s].inspect}~~~~~~"
    @spec[params.to_s] ||= get_spec(params.clone)
  end

  def get_spec(params={})
    Rails.logger.info "get_spec called with #{params.inspect}"
    spec = ::User.as(:wagbot) do ## why is this a wagbot thing?  can't deny search content??
      spec_content = raw_content
      raise("Error in card '#{self.name}':can't run search with empty content") if spec_content.empty?
      JSON.parse( spec_content )
    end
    spec.symbolize_keys!.merge! params.symbolize_keys
    if default_limit = spec.delete(:default_limit) and !spec[:limit]
      spec[:limit] = default_limit
    end
    spec[:context] ||= (name.junction? ? name.left_name : name)
    spec
  end
  
  def escape_content
    self.content = CGI::unescapeHTML( URI.unescape(content) )
  end
  
end
