module Wagn::Set::Self::Create
  module Model
    def config key=nil
      @configs||={
        :group=>:perms,
        :seq=>1
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
