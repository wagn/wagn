module Pattern
  class << self
    @@store = {}
    
    def create( spec )
      matching_classes = active_classes.select {|pattern_class| pattern_class.recognize( spec ) }
      raise("invalid pattern") if matching_classes.length < 1
      raise("pattern conflict") if matching_classes.length > 1
      matching_classes.first.new( spec )
    end 
    
    def register( pattern )      
      @@store[ pattern.to_key ] ||= []
      @@store[ pattern.to_key ] << pattern
    end
    
    def patterns_for(card)
      card.pattern_keys ||= keys_for(card)
      card.pattern_keys.map { |key| @@store[ key ] }.flatten.order_by(&:priority)
    end                                                          
    
    def cards_for(pattern)
      Card.search( pattern.to_wql )
    end

    private
    def keys_for(card)
      active_classes.map { |pattern_class| pattern_class.key_for(card) }.compact
    end
    
    def active_classes
      subclasses & System.setting('*active pattern classes') 
    end
  end
  
  class Base
    def self.key_for(card)
      raise("not implemented")
    end
  
    def self.recognize(wql)
      raise("not implemented")
    end
    
    def intialize(spec)
      @spec = spec
    end
    
    def to_key
      raise("not implemented")
    end
    
    def to_wql
      @spec
    end
  end
end                                                                     



     
class TypePattern < Pattern::Base
  def self.key_for(card)
    "Type:#{card.type}"
  end 

  def self.recognize(spec)
    spec[:type] && spec[:type].is_a?(String) && spec.keys.length == 1
  end
  
  def to_key
    "Type:#{@spec[:type]}"                        
  end 
end


class RightNamePattern < Pattern::Base
  def self.key_for(card)
    return nil unless card.junction?
    "RightName:#{card.name.tag_name}"
  end
  
  def self.recognize(spec)
    spec[:right] && spec[:right].is_a?(String) && spec.keys.length == 1
  end
  
  def to_key
    "RightName:#{spec[:right]}"
  end
end


class TypeRightNamePattern < Pattern::Base
  def self.key_for(card)
    return nil unless card.junction?
    "TypeRightName:#{card.type}:#{card.name.tag_name}"
  end
  
  def self.recognize(spec) 
    spec[:right] && spec[:right].is_a?(String) &&
      spec[:type] && spec[:type].is_a?(String) &&
      spec.keys.length == 2
  end                                
  
  def to_key
    "TypeRightName:#{spec[:type]}:#{spec[:right]}"
  end
end

