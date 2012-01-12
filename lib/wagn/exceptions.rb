module Wagn
  module Exceptions
    Error               = Class.new StandardError
    NotFound            = Class.new Error
    BadAddress          = Class.new Error
    PermissionDenied    = Class.new Error
    Oops                = Class.new Error
  end
  def self.included(base)
    Card.extend Exceptions
    base.extend Exceptions
  end
end
