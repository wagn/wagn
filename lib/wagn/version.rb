# -*- encoding : utf-8 -*-
module Wagn::Version
  class << self
    def release
      @@version ||= File.read( File.join Rails.root, 'VERSION' )
    end
    
    def schema type=nil
      File.read( schema_stamp_path type ).strip
    end
    
    def schema_stamp_path type
      suffix = type.to_s =~ /card/ ? '_cards' : ''
      schema_stamp_dir + "version#{ suffix }.txt"  
    end
    
    def schema_stamp_dir
      Wagn::Application.config.paths['config/database'].first.sub /[^\/]*$/, ''
    end
    
  end
end
