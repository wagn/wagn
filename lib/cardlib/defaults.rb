module Cardlib
  module Defaults
    def self.included(base)   
      super 
      base.extend(ClassMethods)   
      base.class_eval do
#        class_inheritable_accessor :editor_type, :description
#        set_editor_type "RichText"
      end
    end      
    module ClassMethods 

    end
    
    # -- called by the rendering pipeline-- defined in datatypes
    def allow_duplicate_revisions
      false
    end
        
    def cacheable?
      return true
    end
    
    def post_render( content )
      # FIXME-- client code shouldn't have to know to do this i don't think?
      # content.replace(newcontent) 
      content
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
