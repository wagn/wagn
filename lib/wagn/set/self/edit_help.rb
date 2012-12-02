module Wagn::Set::Self::EditHelp
  module Model
    def config key=nil
      @configs||={
        :group=>:com,
        :seq=>11
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
