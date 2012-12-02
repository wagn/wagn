module Wagn::Set::Self::Update
  module Model
    def config key=nil
      @configs||={
        :group=>:perms,
        :seq=>3
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
