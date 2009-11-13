module Wagn
  class Pattern
    @@subclasses = []

    class << self
      def register_class klass 
        @@subclasses << klass
      end
    
      def class_for spec
        matching_classes = @@subclasses.select {|pattern_class| pattern_class.recognize( spec ) }
        raise("invalid pattern #{spec.inspect}") if matching_classes.length < 1
        raise("pattern conflict for #{spec.inspect}: matched by #{matching_classes.inspect}") if matching_classes.length > 1
        matching_classes.first
      end
    
      def key_for_spec spec
        class_for(spec).key_for_spec spec
      end
    
      def keys_for_card card
        @@subclasses.map { |pattern_class| pattern_class.key_for_card(card) }.compact
      end
    end  
   
    attr_reader :spec
  
    def initialize spec
      @spec = spec
    end
  end                                                                     

  class TypePattern < Pattern
    class << self
      def key_for_card card
        "Type:#{card.type}"
      end 

      def recognize spec
        spec[:type] && spec[:type].is_a?(String) && spec.keys.length == 1
      end

      def key_for_spec spec
        "Type:#{spec[:type]}"                        
      end    
    end
    register_class self
  end

  class RightNamePattern < Pattern 
    class << self
      def key_for_card card
        return nil unless card.junction?
        "RightName:#{card.name.tag_name}"
      end
  
      def recognize spec
        spec[:right] && spec[:right].is_a?(String) && spec.keys.length == 1
      end
  
      def key_for_spec spec
        "RightName:#{spec[:right]}"
      end
    end
    register_class self
  end

  class LeftTypeRightNamePattern < Pattern                     
    class << self
      def key_for_card card
        return nil unless card.junction?      
        "LeftTypeRightName:#{card.left.type}:#{card.name.tag_name}"
      end
  
      def recognize spec
        !!(spec[:right] && spec[:right].is_a?(String) &&
              spec[:left] && spec[:left].is_a?(Hash) && spec[:left][:type])
      end                                
  
      def key_for_spec spec
        "LeftTypeRightName:#{spec[:left][:type]}:#{spec[:right]}"
      end
    end
    register_class self
  end   
end   

