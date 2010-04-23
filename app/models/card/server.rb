module Card
	class Server < Base
    def post_render( content )
      res = if System.enable_server_cards
        '<pre>' + Shellbox.new.run( content ) + '</pre>'
      else  
        'sorry, server cards are not enabled'
      end
      content.replace( res )
    end

    def cacheable?
      false
    end
  
	end
end
