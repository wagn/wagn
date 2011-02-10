module Card

  class Search < Base
    attr_accessor :self_cardname, :results, :spec
    before_save :escape_content

    def is_collection?() true end

    def escape_content
      self.content = CGI::unescapeHTML( URI.unescape(content) )
    end

    def count(params={})
      Card.count_by_wql( spec(params) )
    end

    def search( params={} )
      spec(params)
      raise("OH NO.. no limit") unless @spec[:limit]
      @spec.delete(:limit) if @spec[:limit].to_i <= 0
      # FIXME CACHE TODO: optimize by loading these into the cache.
      self.results = Card.search( @spec )
    end

    def each_name  
      ## FIXME - this should just alter the spec to have it return name rather than instantiating all the cards!!  
      ## (but need to handle prepend/append)
      Wql.new(card.get_spec).run.map do
        |card| yield(card.name)
      end
    end
    
    def spec(params={})
      if params.empty? && @spec
        @spec
      else
        @spec = get_spec(params.clone)
      end
    end

    def get_spec(params={})
      spec = ::User.as(:wagbot) do
        spec_content = templated_content || self.content
        raise("Error in card '#{self.name}':can't run search with empty content") if spec_content.empty?
        JSON.parse( spec_content )
      end
      # FIXME: should unit test this

      self_cardname ||= ( name.junction? ? name.parent_name : nil )

      if spec.is_a?(Hash) && self_cardname
        spec[:_self] = self_cardname
      end
      spec.merge! params
      spec.symbolize_keys!
      spec
    end
  end
end
