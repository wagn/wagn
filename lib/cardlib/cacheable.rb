module Cardlib
  module Cacheable
    
    def template?
      name && name.template_name?
    end
       
    def type_template?
      name && name.template_name? && name =~ /\*type/
    end

    def right_template?
      name && name.template_name? && name =~ /\*right/
    end
       
    def hard_template?
      !soft_template?
    end

    def soft_template?
      name && name =~ /\*default/
    end
    
    def auto_template?
      name && name =~ /\*virtual/
    end
    

	  def pointees
	    User.as(:wagbot) do
  	    links = content.split(/\n+/).map{ |x| x.gsub(/\[\[|\]\]/,'')}
	    end
	  end
	  
	  def pointee
	    pointees.first
    end
  end
end