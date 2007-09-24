module Card
	class Query < Base
    before_save :escape_content

    def escape_content
      #warn "Escaped #{content}"
      self.content = CGI::unescapeHTML( URI.unescape(content) )
      #warn "UnEscaped #{content}"
    end

    def post_render( content )
      args = options_from_content( content )
      #warn "Query #{content} args=#{args.inspect}"
      cards = Card.find_by_wql_options( args )

      if cards.length==0
        "No cards matched this query"
      else
        #warn "CARDS: #{cards.inspect}"
        "FIXME: tag cloud should be here!"
        #Renderer.instance.controller.send(:render_to_string, :partial=>'block/tag_cloud', 
        #:locals=>{ :card=>self, :cards => cards })
      end
      #rescue Exception=>e
      #  return "Error processing query: #{e.message}"
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

  

  end
end
