module Cardlib
  module Settings
    
    def setting setting_name
      card = setting_card setting_name
      return card && card.content
    end
    
    def setting_card setting_name
      # look for pattern
      Wagn::Pattern.keys_for_card( self ).each do |key|
        if pattern_card = Card.find_by_pattern_spec_key( key )
          if setting_card = CachedCard.get_real( "#{pattern_card.name}+#{setting_name.to_star}" ) 
            return setting_card
          end
        end
      end

      return self.class.default_setting_card(setting_name) 
    end
    
    
    module ClassMethods
      def default_setting setting_name
        card = default_setting_card setting_name
        return card && card.content
      end
      
      def default_setting_card setting_name
        setting_card = CachedCard.get_real( "*all+#{setting_name.to_star}" ) 
      end
    end
      
    def self.append_features(base)
      super
      base.extend(ClassMethods)
    end

  end
end