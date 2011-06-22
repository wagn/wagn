module Wagn::Card::Settings
  def setting setting_name, fallback=nil
    card = setting_card setting_name, fallback
    card && begin
      User.as(:wagbot){ card.content }
    end
  end
  
  def setting_card setting_name, fallback=nil
    Wagn::Pattern.set_names( self ).each do |name|
      next unless Card.fetch(name, :skip_virtual=>true) 
      # optimization for cases where there are lots of settings lookups for many sets though few exist. 
      # May cause problems if we wind up with Set in trash, since trunks aren't always getting pulled out when we
      # create plus cards (like setting values)
      if value = Card.fetch( "#{name}+#{setting_name.to_s.to_star}" , :skip_virtual => true)
        return value
      elsif fallback and value2 = Card.fetch("#{name}+#{fallback.to_s.to_star}", :skip_virtual => true)
        return value2              
      end
    end
    return nil
  end

  module ClassMethods
    def default_setting setting_name, fallback=nil
      card = default_setting_card setting_name, fallback
      return card && card.content
    end
    
    def default_setting_card setting_name, fallback=nil
      setting_card = Card.fetch( "*all+#{setting_name.to_s.to_star}" , :skip_virtual => true) or 
        (fallback ? default_setting_card(fallback) : nil)
    end
  end
    
  def self.append_features(base)
    super
    base.extend(ClassMethods)
  end
end
