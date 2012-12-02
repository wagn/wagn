module Wagn::Set::Self::Layout
  module Model
    def config key=nil
      @configs||={
        :group=>:look,
        :seq=>8
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
