module Wagn
  module Cache
    class << self
      def reset_local
        User.clear_cache if System.multihost
        Cardtype.reset_cache
        Role.reset_cache
        System.reset_cache
        CachedCard.reset_cache
      end
    
      def reset_global
        CachedCard.bump_global_seq
      end
    end
  end
end