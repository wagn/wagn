module Wagn::Set::Self::Comment
  module Model
    def config key=nil
      @configs||={
        :group=>:perms,
        :seq=>5
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
