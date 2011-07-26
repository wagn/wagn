class Cardtype < ActiveRecord::Base
  self.extend Wagn::Model::ActsAsCardExtension 
  acts_as_card_extension  
  
  class << self
    def reset_cache
      @@cache ||= {}
      @@cache[System.wagn_name] = {}
    end

    def cache
      @@cache ||= {}
      @@cache[System.wagn_name] ||= {}
    end
    
    def load_cache
      Rails.logger.debug "load_cardtype_cache"
      c = self.cache 
      c[:card_keys  ] = {}
      c[:card_names ] = {}
      c[:class_names] = {}

      Card.connection.select_all(%{
        select distinct ct.class_name, c.name, c.key
        from cardtypes ct 
        join cards c on c.extension_id=ct.id and c.extension_type='Cardtype'    
        where c.trash is false
      }).each do |rec|
        self.cache[:card_keys][rec['key']] = rec['name']
        self.cache[:card_names][rec['class_name']] = rec['name'];   
        self.cache[:class_names][rec['key']] = rec['class_name']
      end
    end

    def name_for_key?(key)
      load_cache if self.cache.empty?      
      Rails.logger.debug "name_for_key (#{key.inspect}) #{self.cache[:card_keys].inspect}"
      self.cache[:card_keys].has_key?(key)
    end

    def name_for_key(key)
      load_cache if self.cache.empty?
      Rails.logger.debug "name_for_key (#{key.inspect}) #{self.cache[:card_keys].inspect}"
      self.cache[:card_keys][key] || raise("No card name for key #{key}")
    end
    
    # this is the only one that goes code (as camelized typecode) to name
    def name_for(classname)
      load_cache if self.cache.empty?
      self.cache[:card_names][classname] || begin
        Rails.logger.debug "name_for (#{classname.inspect}) #{self.cache[:card_names].inspect}"; nil
        raise("No card name for class #{classname}") 
      end
    end

    def classname_for(card_name) 
      load_cache if self.cache.empty?
      Rails.logger.debug "classname_for #{card_name} #{card_name.to_key}, #{self.cache[:class_names][card_name.to_key].inspect}"
      self.cache[:class_names][card_name.to_key] || raise("No class name for cardtype name #{card_name}") 
    end
    
    def createable_types  
      load_cache if self.cache.empty?
      self.cache[:card_names].collect do |codename,card_name|
        next if ['InvitationRequest','Setting','Set'].include?(codename)
        next unless create_ok?(codename)
        { :codename=>codename, :name=>card_name }
      end.compact.sort_by {|x| x[:name].downcase }
    end   
    
    def create_ok?( codename )
      Card.new( :typecode=>codename, :skip_defaults=> true).ok? :create
    end
  end        
  
  def codename
    class_name
  end
  
end
