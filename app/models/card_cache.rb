module CardCache 
  class CachedCard < Struct.new(:name, :type, :permissions, :content)
  end
  
  class << self
    def instance
      ActionController::Base.fragment_cache_store
    end
      
    # supports 
    # read(key)
    # delete(key)
    # write(key,content)
    #
    # FIXME: later intercept these to make domain specific?
    def method_missing?(method, *args)
      instance.send(method,*args)
    end  
    
    def [](key)
      data = instance.read(key).split('|') 
      permissions = data[2].split(';').inject({}){|h,p| k,v=p.split(':'); h[k]=v.split('.'); h }
      CachedCard.new( data[0], data[1], permissions, data[3..-1].join('|'))
    end                  
    
    def after_save(card)  
      data = [ 
        card.name, 
        card.type,
        card.permissions.collect{|p| "#{p.task}:#{p.party_type}.#{p.party_id}" }.join(';'),
        card.content
      ].join('|')
      
      instance.write( card.key, data )
    end
    
    def after_destroy(card)
      instance.delete( card.key )
    end
  end
end