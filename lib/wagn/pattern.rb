module Wagn
  class Pattern
    @@subclasses = []

    class << self
      def register_class klass 
        @@subclasses.unshift klass
      end
    
      def set_names card
        @@subclasses.map do |sc|
          sc.pattern_applies?(card) ? sc.set_name(card) : nil
        end.compact << "*all"
      end
    end  
   
    attr_reader :spec
  
    def initialize spec
      @spec = spec
    end
  end                                                                     

  class TypePattern < Pattern
    class << self
      def pattern_applies? card
        true
      end

      def set_name card
        "#{card.cardtype.name}+*type"
      end
      
    end
    register_class self
  end

  class RightNamePattern < Pattern 
    class << self
      def pattern_applies? card
        card.name && card.name.junction?
      end
  
      def set_name card
        "#{card.name.tag_name}+*right"
      end
    end
    register_class self
  end

  class LeftTypeRightNamePattern < Pattern                     
    class << self
      def pattern_applies? card
        card.name && card.name.junction? && card.left
      end
      
      def set_name card
        "#{card.left.cardtype.name}+#{card.name.tag_name}+*type plus right"
      end
    end
    register_class self
  end
  
  class SoloPattern < Pattern
    class << self
      def pattern_applies? card
        card.name
      end
      
      def set_name card
        "#{card.name}+*self"
      end
    end
    register_class self
  end
   
end   

