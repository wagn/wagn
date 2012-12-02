
module Wagn::Set::Self::Sol
  module Model
    def config key=nil
      @configs||={
        :trait=>true,
        :seq=>99
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
