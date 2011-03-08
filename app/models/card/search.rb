module Card
  class Search < Base
    attr_accessor :results, :spec
    before_save :escape_content

    def collection?() true end

    def item_cards(params={})
      spec(params)
      raise("OH NO.. no limit") unless @spec[:limit]
      @spec.delete(:limit) if @spec[:limit].to_i <= 0
      self.results = Card.search( @spec )
    end

    def item_names(params={})
      spec(params)
      ## FIXME - this should just alter the spec to have it return name rather than instantiating all the cards!!  
      ## (but need to handle prepend/append)
      Card.search(@spec).map{ |card| card.name}
    end

    def item_type
      spec[:type]
    end

    def count(params={})
      Card.count_by_wql( spec(params) )
    end

    def spec(params={})
      if params.empty? && @spec
        @spec
      else
        @spec = get_spec(params.clone)
      end
    end

    def get_spec(params={})
      spec = ::User.as(:wagbot) do ## why is this a wagbot thing?
        spec_content = raw_content
        raise("Error in card '#{self.name}':can't run search with empty content") if spec_content.empty?
        JSON.parse( spec_content )
      end
      spec[:context] ||= (name.junction? ? name.left_name : name)
      spec.merge! params
      spec.symbolize_keys!
      spec
    end
    
    def escape_content
      self.content = CGI::unescapeHTML( URI.unescape(content) )
    end
    
  end
end
