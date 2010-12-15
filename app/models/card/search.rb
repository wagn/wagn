module Card      
  
  class Search < Base  
    attr_accessor :self_cardname, :results, :spec
    before_save :escape_content

    def escape_content
      self.content = CGI::unescapeHTML( URI.unescape(content) )
    end
    
    def cacheable?
      name.template_name? 
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
