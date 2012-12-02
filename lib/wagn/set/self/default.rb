module Wagn::Set::Self::Default
  module Model
    def config key=nil
      @configs||={
        :group=>:look,
        :seq=>6
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
