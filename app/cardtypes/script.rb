module Card
	class Script < Base
    def content_for_rendering 
      begin
        if System.enable_server_cards
          Shellbox.new.run( content )
        else  
          'sorry, server cards are not enabled'
        end
      rescue Exception=>e
        e.message
      end
    end

    def cacheable?
      false
    end
	end
end
