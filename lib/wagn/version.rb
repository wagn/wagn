# -*- encoding : utf-8 -*-
require 'wagn'

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
        File.join schema_stamp_dir, "/version#{ suffix }.txt"  
      end
    
      def schema_stamp_dir
        File.join Wagn.gem_root, 'config'
      end
      
    end
  end
end
