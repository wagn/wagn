class Cardtype < ActiveRecord::Base
  self.extend Wagn::Card::ActsAsCardExtension 
  acts_as_card_extension  
  cattr_reader :cache
  
  @@cache={}
  
  class << self
    def reset_cache
      Rails.logger.debug "reset_cardtype_cache"
      @@cache={}
    end
    
    def load_cache
      Rails.logger.debug "load_cardtype_cache"
      @@cache = {   
        :card_keys => {},
        :card_names => {},
        :class_names => {},
        :create_parties => {},
      }

      Card.connection.select_all(%{
        select distinct ct.class_name, c.name, c.key
        from cardtypes ct 
        join cards c on c.extension_id=ct.id and c.extension_type='Cardtype'    
      }).each do |rec|
        @@cache[:card_keys][rec['key']] = rec['name']
        @@cache[:card_names][rec['class_name']] = rec['name'];   
        @@cache[:class_names][rec['key']] = rec['class_name']
        ## error check
      end

      #@@cache[:class_names].values.sort.each do |name|
      #  Card.class_for(name)
      #end
    end

    def name_for_key?(key)
      load_cache if @@cache.empty?      
      Rails.logger.debug "name_for_key (#{key.inspect}) #{@@cache[:card_keys].inspect}"
      @@cache[:card_keys].has_key?(key)
    end

    def name_for_key(key)
      load_cache if @@cache.empty?
      Rails.logger.debug "name_for_key (#{key.inspect}) #{@@cache[:card_keys].inspect}"
      @@cache[:card_keys][key] || raise("No card name for key #{key}")
    end
    
    # this is the only one that goes code (as camelized typecode) to name
    def name_for(classname)
      load_cache if @@cache.empty?
      @@cache[:card_names][classname] || begin
        Rails.logger.debug "name_for (#{classname.inspect}) #{@@cache[:card_names].inspect}"; nil
     # raise("No card name for class #{classname}") 
      end
    end

    def classname_for(card_name) 
      load_cache if @@cache.empty?
      Rails.logger.debug "classname_for #{card_name} #{card_name.to_key}, #{@@cache[:class_names][card_name.to_key].inspect}"
      @@cache[:class_names][card_name.to_key] || raise("No class name for cardtype name #{card_name}") 
    end
    
    def create_party_for(class_name)
      return Role[:auth].id
    end    
    
    def createable_types  
      load_cache if @@cache.empty?
      @@cache[:card_names].collect do |class_name,card_name|
        next if ['InvitationRequest','Setting','Set'].include?(class_name)
        next unless create_ok?(class_name)
        { :codename=>class_name, :name=>card_name }
      end.compact.sort_by {|x| x[:name].downcase }
    end   
    
    def create_ok?(typecode, cardname=nil)
      typecode = classname_for(cardname)||'Basic' unless typecode
      load_cache if @@cache.empty?
      System.role_ok?(create_party_for(typecode))
    end
  end        
  
  def codename
    class_name
  end
  
end
