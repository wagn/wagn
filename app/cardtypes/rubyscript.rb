module Card
  class Rubyscript < Base
    def post_render( content )
      return content.replace("Ruby card disabled") unless System.enable_ruby_cards
      s = Sandbox.new(4)
      s.fuehreAus( content.to_s )
      result = 
        if s.securityViolationDetected
          s.securityViolationText.message
        elsif s.syntaxErrorDetected
          s.syntaxErrorText.message
        else
          s.sandboxOutput.value.to_s
        end     
      content.replace result
    rescue Exception => e
      content.replace e.message
    end

    def cacheable?
      false
    end
  
    def clean_html?
      false
    end
  end
end
