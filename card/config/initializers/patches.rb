module Kaminari
  module Helpers
    class Tag
      include Patches::Kaminari::Helpers::Tag
    end
  end
end

module BetterErrors
  class StackFrame
    include Patches::BetterErrors::StackFrame::TmpPath
  end
end
