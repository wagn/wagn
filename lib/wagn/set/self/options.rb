module Wagn::Set::Self::Options
  module Model
    def config key=nil
      @configs||={
        :group=>:pointer_group,
        :seq=>17
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
