module Wagn::Model::Settings
  def setting setting_name, fallback=nil
    card = setting_card setting_name, fallback
    card && card.content
  end
  
  def setting_card setting_name, fallback=nil
    fetch_args = {:skip_virtual=>true, :skip_after_fetch=>true}
    Wagn::Pattern.set_names( self ).each do |name|
      next unless Card.fetch(name, fetch_args) 
      # optimization for cases where there are lots of settings lookups for many sets though few exist. 
      # May cause problems if we wind up with Set in trash, since trunks aren't always getting pulled out when we
      # create plus cards (like setting values)
      if value = Card.fetch( "#{name}+#{setting_name.to_s.to_star}", fetch_args)
        return value
      elsif fallback and value2 = Card.fetch("#{name}+#{fallback.to_s.to_star}", fetch_args)
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
    
    def universal_setting_names_by_group
      @@universal_setting_names_by_group ||= begin
        setting_names = Card.search(:type=>'Setting', :return=>'name', :limit=>'0') 
        grouped = {:viewing=>[], :editing=>[], :creating=>[]}
        setting_names.each do |name|
          next unless group = Card.setting_attrib(name, :setting_group)
          grouped[group] << name
        end 
        grouped.each_value do |name_list|
          name_list.sort!{ |x,y| Card.setting_attrib(x, :setting_seq) <=> Card.setting_attrib(y, :setting_seq)}      
        end
        grouped
      end
    end
    
    def setting_attrib(name, attrib)
      const = eval("Wagn::Set::Self::#{name.module_name}")
      const.send attrib
    rescue
      Rails.logger.info "nothing found for #{name.module_name}, #{attrib}"
      nil
    end
  end
    
  def self.included(base)
    super
    base.extend(ClassMethods)
  end
  
end
