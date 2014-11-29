# should be able to move these to more appropriate places

warn "wagn.rb trace:#{caller*"\n"}\n #{Card.class}" if Module.constants.include? :Card
WAGN_GEM_ROOT = File.expand_path('../..', __FILE__)
warn "gem root;#{WAGN_GEM_ROOT}"

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
    
    def future_stamp
      ## used in test data
      @@future_stamp ||= Time.local 2020,1,1,0,0,0
    end
  end
end
