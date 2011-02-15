class Renderer
  view(:content, :type=>'ruby') do
    ruby = expand_inclusions( card.content )
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

  view(:editor, :type=>'ruby') do form.text_area :content end
end
