unless defined? Wagn::Version
  module Wagn
    module Version
      Major = '0'
      Minor = '10'
      Tiny  = '0'
    
      class << self
        def to_s
          [Major, Minor, Tiny].join('.')
        end
        
        def minor
          [Major, Minor].join('.')
        end
        
        def to_i
          Major.to_i*10000+Minor.to_i*100+Tiny.to_i
        end
        
        alias :to_str :to_s
      end
    end
  end
end            
