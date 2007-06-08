module Card
  class Role < Base
    after_create :create_extension
    
    def create_extension
      ext = ::Role.create!( :codename => name )
      self.extension_id = ext.id
      self.extension_type = ext.class.to_s
      self.save
    end
    
  end
end
