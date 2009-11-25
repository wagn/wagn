module Wagn
  module Exceptions
  end
  
  class Error < StandardError
  end
  
  class NotFound < Error
  end
  
  class PermissionDenied < Error
  end
  
  class Oops < Error
  end

  class RecursiveTransclude < Error
  end     
  
  class WqlError < Error
  end
end

# FIXME: this is here because errors defined in permissions break without it? kinda dumb
module Card    
  class CardError < Wagn::Error   
    attr_reader :card
    def initialize(card)
      @card = card
      super build_message 
    end   
    
    def get_card
      @card
    end 
    
    def build_message
      "#{@card.name} has errors: #{@card.errors.full_messages.join(', ')}"
    end
  end
end
  
