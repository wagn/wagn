require 'datatypes/plain_text_datatype' 
require 'lib/shellbox'
class ServerDatatype < PlainTextDatatype
  register "Server"
  description %{
    Enter a command to be run on your server.
  }
  
  def content_for_rendering
    if System.enable_server_cards
      '<pre>' + Shellbox.new.run( @card.content ) + '</pre>'
    else  
      'sorry, server cards are not enabled'
    end
  end
  
  def cacheable?
    false
  end
end


