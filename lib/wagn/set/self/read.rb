module Wagn::Set::Self::Read
  module Model
    def config key=nil
      @configs||={
        :group=>:perms,
        :seq=>2
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
