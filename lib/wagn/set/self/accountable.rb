module Wagn::Set::Self::Accountable
  module Model
    def config key=nil
      @configs||={
        :group=>:other,
        :seq=>99
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
