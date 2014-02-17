# -*- encoding : utf-8 -*-
module Wagn
  class NotFound < StandardError
  end
  
  class BadAddress < StandardError
  end
  
  class PermissionDenied < Error # can remove after obviating admin controller
  end
end
