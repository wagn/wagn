# should be able to move these to more appropriate places

WAGN_ROOT = File.expand_path('') # need more sophistication here!
WAGN_GEM_ROOT = File.expand_path('../..', __FILE__)
ENGINE_ROOT = WAGN_ROOT # needed for generators

module Wagn

  def self.root
    WAGN_ROOT
  end
      
  def self.gem_root
    WAGN_GEM_ROOT
  end
  
end