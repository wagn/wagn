class Shellbox
  def run(cmd)
    Dir.chdir( RAILS_ROOT + '/public_scripts')
    IO.popen("/usr/bin/env PATH='.' /bin/bash --restricted", "w+") do |p|
      p.puts cmd
      p.close_write
      p.read
    end
  end
end

class Wagn::Renderer
  define_view(:naked, :type=>'script') do
    command = process_content( card.content )
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
  
  alias_view( :editor, {:type=>'plain_text'},  {:type=>'script'} )

  define_view(:naked, :type=>'ruby') do
    ruby = process_content( card.content )
    begin
      if System.enable_ruby_cards
        s = Sandbox.new(4)
        s.fuehreAus( ruby )
        result = if s.securityViolationDetected
            s.securityViolationText.message
          elsif s.syntaxErrorDetected
            s.syntaxErrorText.message
          else
            s.sandboxOutput.value.to_s
          end
      else
        "Ruby cards disabled" #ENGLISH
      end
    rescue Exception => e
      CGI.escapeHTML( e.message )
    end
  end

  define_view(:editor, :type=>'ruby') do
    form.text_area :content
  end
end
