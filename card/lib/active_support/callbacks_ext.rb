module ActiveSupport
  module Callbacks
    class Callback
      def applies? object
        conditions_lambdas.all? { |c| c.call(object, nil) }
      end
    end
  end
end
