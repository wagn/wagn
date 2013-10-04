# -*- encoding : utf-8 -*-
module Wagn
  module Exceptions
    class Error     < StandardError ; end
    class NotFound          < Error ; end
    class BadAddress        < Error ; end
    class PermissionDenied  < Error ; end
    class Oops              < Error ; end
  end
end
