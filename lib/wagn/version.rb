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

      private    
    
      def schema_stamp_path type
        File.join Wagn.gem_root, 'config', "version#{ '_cards' if type.to_s =~ /card/ }.txt"  
      end
      
    end
  end
end
