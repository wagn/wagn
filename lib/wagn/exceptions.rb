module Wagn
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