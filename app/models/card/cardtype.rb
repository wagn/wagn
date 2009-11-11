 module Card
  class Cardtype < Base
    ## FIXME -- needs to create constant-safe class name and validate its uniqueness 
    before_validation_on_create :create_extension
    after_save :reload_cardtypes
    
    before_destroy :ensure_not_in_use, :destroy_extension   # order is important!
    after_destroy :reload_cardtypes
    
    #validates_presence_of :extension
                                       
    def codename
      extension ? extension.class_name : nil
    end

    def set_codename(codename)
      extension.class_name = codename
      extension.save
    end

    def approve_codename
    end
    
    tracks :codename

    def create_extension
      class_name = ::Card.generate_codename_for(name)
      newclass = Class.new( ::Card::Basic )
      ::Card.const_set class_name, newclass
      self.extension = ::Cardtype.create!( :class_name => class_name )
      self.extension
    end
    
    def me_type
      self.extension && Card.const_get( self.extension.class_name )
    end
    
    def queries
      super.unshift 'cardtype_cards'
    end


    private
    
    def on_type_change
      ensure_not_in_use
      destroy_extension
      reload_cardtypes
    end
    
    # FIXME -- the current system of caching cardtypes is not "thread safe":
    # multiple running ruby servers could get out of sync re: available cardtypes  
    def reload_cardtypes
      ::Cardtype.send(:load_cache)
    rescue
    end
    
    def ensure_not_in_use
      if extension and Card.search(:type=>name).length > 0
        errors.add :destroy, "Can't remove Cardtype #{name}: cards of this type still exist"
        return false
      end
    end
    
    
    def validate_type_change
      validate_destroy
    end
    
    def validate_destroy
      if extension and ::Card.find_by_type_and_trash( extension.codename, false ) 
        errors.add :type, "can't be altered because #{name} is a Cardtype and cards of this type still exist"
      end
      super
    end
    
    
  end
end