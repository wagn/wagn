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
        stamp_dir = ENV['SCHEMA_STAMP_PATH'] || if type.to_s =~ /deck/
          File.join( Wagn.root, 'config' )
        else
          File.join( Wagn.gem_root, 'config' )
        end 
        
        File.join stamp_dir, "version#{ '_cards' if type.to_s =~ /card|deck/ }.txt"  
      end
            
    end
  end
end
