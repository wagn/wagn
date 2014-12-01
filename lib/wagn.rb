# should be able to move these to more appropriate places
WAGN_GEM_ROOT = File.expand_path('../..', __FILE__)

module Wagn

  class << self    
    def root
      Rails.root
    end
  
    def application
      Rails.application
    end
    
    def config
      application.config
    end
    
    def paths
      application.paths
    end
    
    def gem_root
      WAGN_GEM_ROOT
    end
    
    def with_logging cardname, method, message, details, &block
      if Wagn.config.performance_logger and 
         Wagn.config.performance_logger[:methods] and 
         Wagn.config.performance_logger[:methods].include? method        
        Wagn::Log.start_block :cardname=>cardname, :method=>method, :message=>message, :details=>details
        result = block.call
        Wagn::Log.finish_block
        result
      else
        block.call
      end
    end
    
    def future_stamp
      ## used in test data
      @@future_stamp ||= Time.local 2020,1,1,0,0,0
    end
  end
end
