module Wagn
  class Pattern
    @@subclasses = []
    cattr_accessor :key
    @@cache = {}

    class << self
      def reset_cache
        @@cache = {}
      end
      
      def register_class klass 
        @@subclasses.unshift klass
      end
      
      def subclasses
        @@subclasses
      end
    
      def set_names card
        card.new_record? ? generate_set_names(card) : 
          (@@cache[(card.name ||"") + (card.type||"")] ||= generate_set_names(card))
      end
      
      def generate_set_names card
        @@subclasses.map do |sc|
          sc.pattern_applies?(card) ? sc.set_name(card) : nil
        end.compact  
      end

      def css_names card
        set_names(card).map do |sn|
          if sn == "*all"
            "ALL"
          else
            sn.tag_name.gsub(' ','_').gsub('*','').upcase + '-' + sn.trunk_name.css_name
          end
        end.reverse.join(" ")
      end
      
      def label name
        @@subclasses.map do |sc|
          return sc.label(name) if sc.match(name)
        end
        return nil
      end
            
      def match name
        name.tag_name==self.key
      end

      # def css_name card
      #   sn = set_name card
      #   sn.tag_name.gsub(' ','_').gsub('*','').upcase + '-' + sn.trunk_name.css_name
      # end
    end  
   
    attr_reader :spec
  
    def initialize spec
      @spec = spec
    end
    
    
  end                                                                     

  class AllPattern < Pattern
    class << self
      def key
        '*all'
      end
      
      def pattern_applies? card
        true
      end

      def set_name card
        key
      end
      
      # def css_name card
      #   "ALL"
      # end
      
      def label name
        'All Cards'
      end
    end
    register_class self
  end

  class TypePattern < Pattern
    class << self
      def key
        '*type'
      end
      
      def pattern_applies? card
        true
      end

      def set_name card
        "#{card.cardtype_name}+#{key}"
      end
      
      def label name
        "All #{name.trunk_name} cards"
      end
    end
    register_class self
  end

  class RightNamePattern < Pattern 
    class << self
      def key
        '*right'
      end
      
      def pattern_applies? card
        card.name && card.name.junction?
      end
  
      def set_name card
        "#{card.name.tag_name}+#{key}"
      end
      
      def label name
        "Cards ending in +#{name.trunk_name}"
      end
    end
    register_class self
  end

  class LeftTypeRightNamePattern < Pattern                     
    class << self
      def key
        '*type plus right'
      end
      
      def pattern_applies? card
        card.name && card.name.junction? && left(card)
      end
      
      def left card
        card.loaded_trunk || card.left
      end
      
      def set_name card
        "#{left(card).cardtype_name}+#{card.name.tag_name}+#{key}"
      end
      
      def label name
        "Any #{name.trunk_name.trunk_name} card plus #{name.trunk_name.tag_name}"
      end
    end
    register_class self
  end
  
  class SoloPattern < Pattern
    class << self
      def key
        '*self'
      end
      
      def pattern_applies? card
        card.name and !card.virtual? and !card.new_record?
      end
      
      def set_name card
        "#{card.name}+#{key}"
      end
      
      def label name
        "Just \"#{name.trunk_name}\""
      end
    end
    register_class self
  end
   
end   

