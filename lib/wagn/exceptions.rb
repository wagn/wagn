module Wagn
  module Exceptions
    Error               = Class.new StandardError
    NotFound            = Class.new Error
    PermissionDenied    = Class.new Error
    Oops                = Class.new Error
    RecursiveTransclude = Class.new Error
    WqlError            = Class.new Error
  end
end
