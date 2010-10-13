module Cardlib
  module Settings
    Fallbacks = {
      '*add help' => '*edit help',
      '*content' => '*default'
    }
    
    def setting setting_name
      card = setting_card setting_name
      card && begin
        User.as(:wagbot){ card.content }
      end
    end
    
    def setting_card setting_name
      ## look for pattern
      Wagn::Pattern.set_names( self ).each do |name|
        if sc = Card.fetch( "#{name}+#{setting_name.to_star}" , :skip_virtual => true)
          return sc
        elsif fallback=Fallbacks[setting_name.to_star] and sc = Card.fetch("#{name}+#{fallback}", :skip_virtual => true)
          return sc              
        end
      end
      return nil
    end

    module ClassMethods
      def default_setting setting_name
        card = default_setting_card setting_name
        return card && card.content
      end
      
      def default_setting_card setting_name
        setting_card = Card.fetch( "*all+#{setting_name.to_star}" , :skip_virtual => true)
      end
    end
      
    def self.append_features(base)
      super
      base.extend(ClassMethods)
    end

  end
end