module Card
  class Setting < Base  
    attr_accessor :codename
    
    after_create :create_extension
    
    def create_extension
      ext = ::Setting.create! :codename => (codename.blank? ? name.to_codename : codename)
      self.extension_id = ext.id
      self.extension_type = ext.class.to_s
      self.save
    end
    
  end
end