module Wagn::Model::Settings
  def setting setting_name, fallback=nil
    card = setting_card setting_name, fallback
    card && card.content
  end
  
  def setting_cache() @setting_cache ||= {} end
  def reset_setting_cache() @setting_cache = {} end

  def setting_card setting_name, fallback=nil
    fetch_args = {:skip_virtual=>true, :skip_after_fetch=>true}
  
    setting_cache.has_key?(setting_name) and
    #value = setting_cache[setting_name] and
    begin
      Rails.logger.info "cached setting[#{name}]( #{setting_name}, #{fallback}) => #{setting_cache[setting_name].inspect}"
      return setting_cache[setting_name]
    end
    #rule_name = nil #if pattern =
    value=nil
    if real_set_names.detect do |name|
        value = Card.fetch("#{name}+#{setting_name.to_s.to_star}", fetch_args) or
            fallback and Card.fetch("#{name}+#{fallback.to_s.to_star}", fetch_args)
          #Card.fetch((rule_name="#{name}+#{setting_name.to_s.to_star}"), fetch_args) or
          #  fallback and
          #  Card.fetch((rule_name="#{name}+#{fallback.to_s.to_star}"), fetch_args)
      end
      #setting_cache[setting_name+"-rule-name"] = rule_name
    end
    Rails.logger.info "caching setting[#{name}](#{setting_name}) => #{value.inspect}"
    setting_cache[setting_name] = value
  end

  def related_sets
    sets = []
    sets<< "#{name}+*type" if typecode=='Cardtype'
    if name.simple?
      sets<< "#{name}+*right"
      Card.search(:type=>'Set',:left=>{:right=>name},:right=>'*type plus right',:return=>'name').each do |set_name|
        sets<< set_name
      end
    end
    sets
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
        grouped = {:view=>[], :edit=>[], :add=>[]}
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
