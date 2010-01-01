class Cardtype < ActiveRecord::Base
  acts_as_card_extension  
  cattr_reader :cache
  #  before_filter :load_cache_if_empty, :only=>[:name_for, :class_name_for, :create_party_for, :createable_cardtypes, :create_ok? ]
  
  @@cache={}
  
  class << self
    def reset_cache
      @@cache={}
    end
    
    def load_cache
      @@cache = {   
        :card_keys => {},
        :card_names => {},
        :class_names => {},
        :create_parties => {},
      }

      Card::Base.connection.select_all(%{
        select distinct ct.class_name, c.name, c.key, p.party_type, p.party_id 
        from cardtypes ct 
        join cards c on c.extension_id=ct.id and c.type='Cardtype'    
        join permissions p on p.card_id=c.id and p.task='create' 
      }).each do |rec|
        @@cache[:card_keys][rec['key']] = rec['name']
        @@cache[:card_names][rec['class_name']] = rec['name'];   
        @@cache[:class_names][rec['key']] = rec['class_name']
        @@cache[:create_parties][rec['class_name']] = rec['party_id']
        ## error check
        unless rec['party_type'] == 'Role'
          raise "Bad Data: create permission for #{rec['class_name']} " +
            "should have party_type 'Role' not '#{rec['party_type']}'"
        end
      end
    end

    def name_for_key?(key)
      load_cache if @@cache.empty?      
      @@cache[:card_keys].has_key?(key)
    end

    def name_for_key(key)
      load_cache if @@cache.empty?
      @@cache[:card_keys][key] || raise("No card name for key #{key}")
    end
    
    def name_for(classname)
      load_cache if @@cache.empty?
      @@cache[:card_names][classname] || raise("No card name for class #{classname}") 
    end

    def classname_for(card_name) 
      load_cache if @@cache.empty?
      @@cache[:class_names][card_name.to_key] || raise("No class name for cardtype name #{card_name}") 
    end
    
    def create_party_for(class_name)
      load_cache if @@cache.empty?
      @@cache[:create_parties][class_name] || raise("No create party for class #{class_name}") 
    end    
    
    def createable_cardtypes  
      load_cache if @@cache.empty?
      @@cache[:card_names].collect do |class_name,card_name|
        next if ['InvitationRequest','Setting','Set'].include?(class_name)
        next unless create_ok?(class_name)
        { :codename=>class_name, :name=>card_name }
      end.compact.sort_by {|x| x[:name].downcase }
    end   
    
    def create_ok?( class_name )          
      load_cache if @@cache.empty?
      System.role_ok?(@@cache[:create_parties][class_name].to_i)
    end
  end        
  
  def codename
    class_name
  end
  
end
