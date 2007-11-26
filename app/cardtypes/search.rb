module Card
	class Search < Base  
	  attr_accessor :self_card, :results, :search_opts
	  attr_accessor :phantom
    before_save :escape_content
    

    def escape_content
      #warn "Escaped #{content}"
      self.content = CGI::unescapeHTML( URI.unescape(content) )
      #warn "UnEscaped #{content}"
    end

    def query_args
      options_from_content( self.content )  
    end

    def options_from_content( content=nil )
      content ||= self.content
      args = CGIMethods.parse_query_parameters( content )
      options = args.keys.inject({}) {|hash,key| hash[key.to_sym]=args[key]; hash }
      options.delete(:type) if options[:type]=='Any'
      options
    end

    def on_revise(content)
      # FIXME- dont' think on_revise is called now.  that mean something broken?
      # nada -- other datatypes update references
    end
    
    def phantom?
      @phantom
    end
    
    def cacheable?
      false
    end
     
    def count(params={})
      params = params.symbolize_keys
      [:offset, :limit].each {|x| params.delete(x) }
#      spec = get_spec(params)
#      warn "COUNT SPEC: #{spec.inspect}"
      Card.count_by_wql( get_spec(params) )
    end
                                
    def search( params={} )  
      self.search_opts = params
      self.results = Card.search( get_spec(params.clone) ).map do |card|
        CachedCard.get(card.name, card)
      end
    end
    
    private 
    def get_spec(params={})
      spec = JSON.parse( self.content )   
      # FIXME: should unit test this    
      self_card ||= ( self.trunk ? self.trunk : nil )
      if spec.is_a?(Hash) && self_card
        spec[:_card] = self_card
      end
      spec.merge! params
      spec
    end

  end
end
