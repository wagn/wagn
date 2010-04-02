module Card      
  
	class Search < Base  
	  attr_accessor :self_cardname, :results, :search_opts, :spec
    before_save :escape_content

    def escape_content
      self.content = CGI::unescapeHTML( URI.unescape(content) )
    end
    
    def cacheable?
      name.template_name? 
    end
     
    def count(params={})
      params = params.symbolize_keys  
      [:offset, :limit].each {|x| params.delete(x) }
      Card.count_by_wql( get_spec(params) )
    end
                                
    def search( params={} )  
      self.search_opts = params  
      self.spec = get_spec(params.clone)
      raise("OH NO.. no limit") unless self.spec[:limit] 
      self.spec.delete(:limit) if spec[:limit] < 0
      self.results = Card.search( self.spec ).map do |card|   
        c = CachedCard.get(card.name, card)
      end
    end
    
    def get_spec(params={})
      spec = ::User.as(:wagbot) do
        raise("Error in card '#{self.name}':can't run search with empty content") if self.content.empty?
        JSON.parse( self.content )   
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
