module Wagn::Set::Self::Send
  module Model
    def config key=nil
      @configs||={
        :group=>:com,
        :seq=>12
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
