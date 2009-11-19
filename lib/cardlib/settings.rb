module Cardlib
  module Settings
    
    def setting setting_name
      card = setting_card setting_name
      return card ? card.content : 'no setting'
    end
    
    def setting_card setting_name
      # look for pattern
      Wagn::Pattern.keys_for_card( self ).each do |key|
        if pattern_card = Card.find_by_pattern_spec_key( key )
          if setting_card = CachedCard.get_real( "#{pattern_card.name}+*#{setting_name}" ) 
            return setting_card
          end
        end
      end

      return default_setting_card(setting_name) 
    end
    
    
    ## this should probably be a class method
    def default_setting_card setting_name
      setting_card = CachedCard.get_real( "*default+*#{setting_name}" ) 
    end

    
    
  end
end