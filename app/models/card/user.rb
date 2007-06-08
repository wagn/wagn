module Card
  class User < Base
    
    def queries
      super<< 'revised_by'
    end
    
    def codename                       
      # FIXME: why do we have User cards without etensions?
      extension ? extension.login : nil
    end
    
=begin    
    after_create :create_extension

    def create_extension
      ext = ::User.create!( 
        :name => name 
      )                      
      #FIXME -- will need several more fields.  And the following three lines should
      # probably inherit from Base
      self.extension_id = ext.id
      self.extension_type = ext.class.to_s
      self.save
    end


    # this was necessary when user was created before the card...    
    def initialize(attributes)
      user = attributes.delete(:user) || raise(":user required for Card::User")
      super(attributes)
      self.extension_id = user.id
      self.extension_type = user.class.to_s
    end
=end
  end  
end