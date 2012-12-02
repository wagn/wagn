module Wagn::Set::Self::Delete
  module Model
    def config key=nil
      @configs||={
        :group=>:perms,
        :seq=>99
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
