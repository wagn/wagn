module Card 
  module Templating
    def template
      @template ||= 
      case
      when template = cardtype.attribute_card('*template');  template
      when tag && tag.plus_template?;   tag.attribute_card('*template')
      else self
      end
    end

    def templatees
      if template? and trunk.class_name =='Cardtype'
        Card.const_get(trunk.extension.class_name).find(:all)
      elsif plus_template?
        tag.left_junctions
      else
        []
      end
    end
    
    def template?
      tag and tag.name == '*template' 
    end
    
    def hard_templatee?
      self.template != self and false #fixme!!
    end

    def templatee?
      self.template != self
    end  
    
    def plus_template?
      simple? and attribute_card('*template') 
    end
    
  end
end
