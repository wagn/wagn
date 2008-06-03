module Card      
  module SearchMethods
     def test
       "" =~ /plus\"\:\[\"([^\"]+)\"\W*refer_to\W*_self/ 
     end
  end
  
	class Search < Base  
	  include SearchMethods
	  attr_accessor :self_card, :results, :search_opts, :spec
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
      self.results = Card.search( self.spec ).map do |card|   
        c = CachedCard.get(card.name, card)
      end
    end
    
    private 
    def get_spec(params={})
      spec = JSON.parse( self.content )   
      # FIXME: should unit test this  
      self_card ||= ( name.junction? ? Card[name.parent_name] : nil )
      if spec.is_a?(Hash) && self_card
        spec[:_card] = self_card
      end
      spec.merge! params
      spec
    end
  end
end
