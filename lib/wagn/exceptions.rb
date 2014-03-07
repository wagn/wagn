# -*- encoding : utf-8 -*-
module Wagn
  class NotFound < StandardError
  end
  
  class BadAddress < StandardError
  end
  
  class PermissionDenied < StandardError # can remove after obviating admin controller
  end
end
