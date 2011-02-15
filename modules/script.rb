class Renderer
  view(:content, :type=>'script') do
    command = expand_inclusions( card.content )
    begin
      if System.enable_server_cards
        Shellbox.new.run( command )
      else  
        'sorry, server cards are not enabled' #ENGLISH
      end
    rescue Exception=>e
      e.message
    end
  end

  view(:editor, :type=>'script') do form.text_area :content, :rows=>3 end
end
