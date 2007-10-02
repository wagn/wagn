module Card
	class Query < Base
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

    def cacheable?
      false
    end

  end
end
