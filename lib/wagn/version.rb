module Wagn::Version
    class << self
      def to_s
        @@version ||= File.read( File.join Rails.root, 'VERSION' )
      end
      alias :to_str :to_s
    end
end
