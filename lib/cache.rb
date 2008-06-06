module CacheMethods 
  def cache(key)
    result = Cache.get(key)
    if result.nil?
      result = yield
      Cache.put(key, result)
    end
    result
  end
  
  def cache_key_prefix
    "/test/"
  end
  
  def read_with_prefix(key)
    read_without_prefix( cache_key_prefix + key )
  end
  
  def write_with_prefix(key, value)   
    write_without_prefix( cache_key_prefix + key, value )
  end
  
  def read_list(key)
    (read(key) || "").split(",")
  end
  
  def write_list(key, array)
    write(key, array.join(","))
  end    
  
  def add_to_uniq_list(key, object)
    write_list(key, (read_list(key) + [object]).uniq )
  end 
  
  def remove_from_list(key, object)
    write_list(key, read_list(key).reject{|x|x==object} )
  end
  
  def system_key(object_key, property)
    object_key + "." + property
  end
  
  def increment_serial_for(object_key)
    serial_key = system_key(object_key, serial)
    write(serial_key, ((read(serial_key)||0).to_i + 1).to_s)
  end       
  
  # FIXME: why am i using these?
  def read(*args)
    ActionController::Base.fragment_cache_store.read(*args)
  end
  
  def write(*args)
    ActionController::Base.fragment_cache_store.write(*args)
  end
end

#Cache = ActionController::Base.fragment_cache_store 
Cache.instance_eval do
  extend CacheMethods
  #alias_method_chain :read, :prefix
  #alias_method_chain :write, :prefix
end
                         
