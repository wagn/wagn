module Wagn::Set::Self::TableOfContent
  module Model
    def config key=nil
      @configs||={
        :group=>:look,
        :seq=>9
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
