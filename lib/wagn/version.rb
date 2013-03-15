module Wagn::Version
    Major = '1'
    Minor = '10'
    Tiny  = '10'
    Eensie = nil

    class << self
      def full
        [Major, Minor, Tiny, Eensie].compact.join('.')
      end

      def to_s
        [Major, Minor, Tiny].join('.')
      end

      def minor
        [Major, Minor].join('.')
      end

      def to_i
        Major.to_i*10000 + Minor.to_i*100 + Tiny.to_i
      end

      alias :to_str :to_s
    end
end
