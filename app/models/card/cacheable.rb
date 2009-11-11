module CardLib
  module Cacheable
    def hard_template?
      extension_type =='HardTemplate'
    end

    def soft_template?
      !hard_template?
    end

	  def pointees
	    User.as(:wagbot) do
  	    links = content.split(/\n+/).map{ |x| x.gsub(/\[\[|\]\]/,'')}
	    end
	  end
	  
	  def pointee
	    pointees.first
    end
    
    
    # FIXME: This api is ok, but the implementation is pretty barf.   
    def setting name, *args
      sd = self.settings_data
      if args.length > 0
        value = args.first
        sd[name] = value
        self.settings_data = sd
      else
        sd[name]
      end
    end                
    
    def settings_data
      self.settings ? YAML.load(self.settings) : {}
    end
    
    def settings_data= data
      self.settings = YAML.dump(data)
    end
  end
end