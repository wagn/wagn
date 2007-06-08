module Card
  class Cardtype < Base
    ## FIXME -- needs to create constant-safe class name and validate its uniqueness 
    after_create :create_extension
    before_destroy :destroy_extension
    
    def codename
      extension.class_name
    end
    
    def create_extension
      class_name = name.gsub(/^\W+|\W+$/,'').gsub(/\W+/,'_').camelize
      ext = ::Cardtype.create!( :class_name => class_name )
      self.extension_id = ext.id
      self.extension_type = ext.class.to_s
      self.save
    end
    
    def cards_of_this_type
      cardtype = self.extension.class_name
      Card.const_get(cardtype).find(:all)
    end
    
    def queries
      super.unshift 'cardtype_cards'
    end
    
    def destroy_extension
      self.extension.destroy
    end
  end
end