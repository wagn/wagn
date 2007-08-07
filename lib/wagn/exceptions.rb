module Wagn
  class ValidationError < StandardError
  end
  
  class InvalidCardRequest < StandardError
  end
  
  class PermissionDenied < StandardError
    attr_reader :card
    def initialize(card)
      @card = card
      super("Permission denied: #{@card.errors.full_messages.join(", ")}")
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