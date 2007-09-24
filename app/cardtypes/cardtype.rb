 module Card
  class Cardtype < Base
    ## FIXME -- needs to create constant-safe class name and validate its uniqueness 
    before_validation_on_create :create_extension
    before_destroy :ensure_not_in_use, :destroy_extension   # order is important!
    after_create :reload_cardtypes
    before_destroy :reload_cardtypes
    
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
      #warn "create extension called!!"
      class_name = name.gsub(/^\W+|\W+$/,'').gsub(/\W+/,'_').camelize
      self.extension = ::Cardtype.create!( :class_name => class_name )
    end
    
    def me_type
      Card.const_get( self.extension.class_name )
    end
    
    def cards_of_this_type
      me_type.find(:all)
    end
    
    def queries
      super.unshift 'cardtype_cards'
    end


    private
    # FIXME -- the current system of caching cardtypes is not "thread safe":
    # multiple running ruby servers could get out of sync re: available cardtypes  
    def reload_cardtypes
      Card.send(:load_cardtypes!)
    end
    
    def destroy_extension
      self.extension.destroy
    end
    
    def ensure_not_in_use
      if cards_of_this_type.length > 0
        errors.add :destroy, "Can't remove Cardtype #{self.extension.class_name}: cards of this type still exist"
        return false
      end
    end
  end
end