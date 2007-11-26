unless defined? Wagn::Version
  module Wagn
    module Version
      Major = '0'
      Minor = '9'
      Tiny  = '0'
    
      class << self
        def to_s
          [Major, Minor, Tiny].join('.')
        end
        
        def minor
          [Major, Minor].join('.')
        end
        
        alias :to_str :to_s
      end
    end
  end
end            
