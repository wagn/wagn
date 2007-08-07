module Card
  class Cardtype < Base
    ## FIXME -- needs to create constant-safe class name and validate its uniqueness 
    before_validation_on_create :create_extension
    before_destroy :ensure_not_in_use, :destroy_extension   # order is important!

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
      class_name = name.gsub(/^\W+|\W+$/,'').gsub(/\W+/,'_').camelize
      self.extension = ::Cardtype.create!( :class_name => class_name )
    end
    
    def cards_of_this_type
      cardtype = self.extension.class_name
      Card.const_get(cardtype).find(:all)
    end
    
    def queries
      super.unshift 'cardtype_cards'
    end


    private
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