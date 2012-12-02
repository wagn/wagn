module Wagn::Set::Self::Captcha
  module Model
    def config key=nil
      @configs||={
        :group=>:other,
        :seq=>98
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
