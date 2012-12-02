module Wagn::Set::Self::OptionsLabel
  module Model
    def config key=nil
      @configs||={
        :group=>:pointer_group,
        :seq=>18
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
