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
        root_dir = ( type == :deck_cards ? Wagn.root : Wagn.gem_root )
        suffix   = Wagn::Migration.schema_suffix type
        stamp_dir = ENV['SCHEMA_STAMP_PATH'] || File.join( root_dir, 'config' )
        
        File.join stamp_dir, "version#{ suffix }.txt"  
      end
            
    end
  end
end
