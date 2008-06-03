require_dependency 'cached_models'

module CardLib
  module Caching   
    module ClassMethods
      # override default find_template to use cache
      def find_template(name)
        CachedCard.get_real(name)
      end
    end
    
    def object_key
      "Card:#{key}"
    end
    
    def bump_dependants_on_save
      GlobalSerial.bump_dependants
      NameFilter.bump_dependants_for(self)
      self.bump_dependants
    end
    
    def bump_dependants_on_create_destroy 
      TypeFilter.bump_dependants_for(self)      
    end
  end
  
  def self.included(base)   
    super
    base.extend(ClassMethods)
    base.class_eval do           
      include Cacheable
      after_save :do_save_bumps
      after_create :do_create_destroy_bumps
      after_destroy :do_create_destroy_bumps
    end
  end
end
                                                 
