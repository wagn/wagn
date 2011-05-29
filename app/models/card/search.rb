module Card

  class Search < Base
    attr_accessor :self_cardname, :results, :spec
    before_save :escape_content

    def collection?() true end

    def item_cards(params={})
      s = spec(params)
      raise("OH NO.. no limit") unless s[:limit] #can be 0 or less to force no limit
      self.results = Card.search( s )
    end

    def item_names(params={})
      ## FIXME - this should just alter the spec to have it return name rather than instantiating all the cards!!  
      ## (but need to handle prepend/append)
      Card.search(spec(params)).map{ |card| card.name}
    end

    def count(params={})
      Card.count_by_wql( (params.empty? && spec) ? spec : get_spec(params) )
    end

    def search( params={} )
      self.spec = get_spec(params.clone)
      raise("OH NO.. no limit") unless self.spec[:limit]
      self.spec.delete(:limit) if spec[:limit].to_i <= 0
      # FIXME CACHE TODO: optimize by loading these into the cache.
      self.results = Card.search( self.spec )
    end

    def spec(params={})
      @spec ||= {}
      @spec[params.to_s] ||= get_spec(params.clone)
    end

    def get_spec(params={})
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
  end
end
