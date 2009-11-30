module Cardlib
  module Settings
    
    def setting knob
      card = setting_card knob
      return card && card.content
    end
    
    def setting_card knob
      # look for pattern
      Wagn::Pattern.keys_for_card( self ).each do |key|
        if pattern_card = Card.find_by_pattern_spec_key( key )
          if setting_card = CachedCard.get_real( "#{pattern_card.name}+*#{knob}" ) 
            return setting_card
          end
        end
      end

      return self.class.default_setting_card(knob) 
    end
    
    
    module ClassMethods
      def default_setting knob
        card = default_setting_card knob
        return card && card.content
      end
      
      def default_setting_card knob
        setting_card = CachedCard.get_real( "*all+*#{knob}" ) 
      end
    end
      
    def self.append_features(base)
      super
      base.extend(ClassMethods)
    end

  end
end