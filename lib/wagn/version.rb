# -*- encoding : utf-8 -*-
require File.expand_path( '../../wagn', __FILE__ )

module Wagn
  module Version
    class << self
      
      def release
        @@version ||= File.read( File.expand_path '../../../VERSION', __FILE__ ).strip
      end
    
      def schema type=nil
        File.read( schema_stamp_path type ).strip
      end
    
      def schema_stamp_path type
        suffix = type.to_s =~ /card/ ? '_cards' : ''
        File.join Wagn.paths['schema-stamp'].first, "/version#{ suffix }.txt"  
      end
      
    end
  end
end
