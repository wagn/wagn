module Wagn::Set::Self::Thanks
  module Model
    def config key=nil
      @configs||={
        :group=>:com,
        :seq=>13
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
