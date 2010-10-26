module Cardlib
  module Settings
    
    def setting setting_name, fallback=nil
      card = setting_card setting_name, fallback
      card && begin
        User.as(:wagbot){ card.content }
      end
    end
    
    def setting_card setting_name, fallback=nil
      ## look for pattern
      Wagn::Pattern.set_names( self ).each do |name|
        if sc = Card.fetch( "#{name}+#{setting_name.to_star}" , :skip_virtual => true)
          return sc
        elsif fallback and sc2 = Card.fetch("#{name}+#{fallback.to_star}", :skip_virtual => true)
          return sc2              
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