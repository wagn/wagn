module Wagn::Set::Self::AddHelp
  module Model
    def config key=nil
      @configs||={
        :group=>:com,
        :seq=>10
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
