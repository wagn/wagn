module Card
	class Server < Base
    def content_for_rendering
      if System.enable_server_cards
        '<pre>' + Shellbox.new.run( content ) + '</pre>'
      else  
        'sorry, server cards are not enabled'
      end
    end

    def cacheable?
      false
    end
  
	end
end
