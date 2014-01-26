# should be able to move these to more appropriate places

WAGN_GEM_ROOT = File.expand_path('../..', __FILE__)

module Wagn

  def self.root
    Rails.root
  end
  
  def self.application
    Rails.application
  end
      
  def self.gem_root
    WAGN_GEM_ROOT
  end
  
end