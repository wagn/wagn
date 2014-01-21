# should be able to move these to more appropriate places

module Wagn

  WAGN_ROOT = File.expand_path('') # need more sophistication here!
  WAGN_GEM_ROOT = File.expand_path('../..', __FILE__)

  def self.root
    WAGN_ROOT
  end
      
  def self.gem_root
    WAGN_GEM_ROOT
  end
  
end