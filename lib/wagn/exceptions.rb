module Wagn
  module Exceptions
    Wagn::Error               = Class.new StandardError
    Wagn::NotFound            = Class.new Error
    Wagn::BadAddress          = Class.new Error
    Wagn::PermissionDenied    = Class.new Error
    Wagn::Oops                = Class.new Error
  end
end
