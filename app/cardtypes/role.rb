module Card
  class Role < Base
    before_create :create_extension
    
    def create_extension
      self.extension = ::Role.create( :codename => name )
    end
    
  end
end
