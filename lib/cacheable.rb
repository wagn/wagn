module Cacheable
  module ClassMethods
    def cache_accessor(*names)
      names.each do |name|
        class_eval %{
          def #{name}
            @#{name} ||= Cache.read property_key('#{name}')
          end
          
          def #{name}=(value)
            Cache.write property_key('#{name}'), value
            @#{name} = value
          end
        }  
      end
    end
  end
  
  def serial
    @serial ||= Cache.read( system_key('serial') ) || '0'   #FIXME: start with a better #?
  end                                                    

  def depend_on(dep_object_key)     
    Cache.add_to_uniq_list self.object_key, dep_object_key 
    Cache.add_to_uniq_list dep_object_key, self.object_key 
  end   
  
  def clear_dependencies
    self.dep_lists.each do |dep_object_key|
      Cache.remove_from_list Cache.system_key(dep_object_key, "dependants"), self.object_key
    end
  end
  
  def bump_dependants
    self.dependants.each do |dep_object_key|
      Cache.increment_serial_for(dep_object_key)
    end
  end  
    
  private   

  def system_key(property)
    Cache.system_key(self.object_key, property)
  end
  
  def property_key(property)
    object_key + "." + serial + "." + property
  end
  
  def self.included(base)   
    super
    base.extend(ClassMethods)
    base.class_eval do           
    end
  end   
  
  def object_key
    raise("Classes using Cacheable must define method 'object_key' (which should start w/cache_key_prefix)")
  end
end