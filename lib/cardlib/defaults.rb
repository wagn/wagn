module Cardlib
  module Defaults
    
    #a place for frequently overridden methods.
    
    def self.included(base)   
      super 
      base.extend(ClassMethods)   
      base.class_eval do
      end
    end
    
    module ClassMethods  #not doing anything now but leaving around for future use.
    end
            
    def post_render( content )
      content
    end
    
    def clean_html?()  true   end
    def generic?()     false  end
    def collection?()  false  end

    def item_names(args={})
      self.raw_content.split /[,\n]/
    end
    
    def item_cards(args={})  ## FIXME this is inconsistent with item_names
      [self]
    end

    def valid_number?( string )
      valid = true
      begin
        Kernel.Float( string )
      rescue ArgumentError, TypeError
        valid = false
      end
      valid    
    end
    # --
  end
end
