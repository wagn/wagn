module Card
  class Role < Basic
    before_validation_on_create :create_extension
    
    def create_extension
      self.extension = ::Role.create( :codename => name )
    end
    
    private
        
    def on_type_change
      destroy_extension
    end
  end
end
