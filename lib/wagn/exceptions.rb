module Wagn
  class ValidationError < StandardError
  end
  
  class InvalidCardRequest < StandardError
  end
  
  class PermissionDenied < StandardError
    attr_reader :card
    def initialize(card)
      @card = card
      super("for card #{@card.name}: #{@card.errors.on(:permission_denied)}")
    end
  end
  
  class Oops < StandardError
  end

  class NoChange < Oops
  end
  
  class RecursiveTransclude < Oops
  end     
  
  class WqlError < StandardError
  end
  
end