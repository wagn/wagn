module Kaminari
  module Helpers
    class Tag
      include Patches::Kaminari::Helpers::Tag
    end
  end
end

if defined? BetterErrors
  module BetterErrors
    class StackFrame
      suppress_warnings { include Patches::BetterErrors::StackFrame::TmpPath }
    end
  end
end

class ActiveRecord::Relation
  include Patches::ActiveRecord::Relation
end
