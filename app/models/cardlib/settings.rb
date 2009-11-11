module Cardlib
  module Settings
    def setting setting_name
      Pattern.keys_for_card( self ).each do |key|
        if pattern_card = Card.find_by_pattern_spec_key( key )
          if setting_card = CachedCard.get( "#{pattern_card.name}+*#{setting}" ) 
            return setting_card.content
          end
        end
      end
      "no setting"
    end
  end
end