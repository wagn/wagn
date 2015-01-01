# -*- encoding : utf-8 -*-
require File.expand_path( '../../wagn', __FILE__ )

module Wagn
  module Version
    class << self

      def release
        @@version ||= File.read( File.expand_path '../../../VERSION', __FILE__ ).strip
      end

    end
  end
end
