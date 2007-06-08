module Wagn
  class ValidationError < StandardError
  end
  
  class InvalidCardRequest < StandardError
  end
  
  class PermissionDenied < StandardError
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