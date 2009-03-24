module Card
  class InvitationRequest < Basic
    attr_accessor :account

    #before_validation_on_create :create_user
    before_destroy :block_user
      
    def cacheable?  
      false # because users who can accept requests need to see different content.
    end

    private
=begin    
    def create_user
      self.extension = ::User.new( self.account )
      extension.generate_password         
      extension.save
      extension.errors.each do |attr,msg| self.errors.add(attr,msg) end
      return false unless extension.valid?
    end
=end
   
    def block_user
      if extension
        extension.update_attributes :status=>'blocked'
      end
    end
    
    def destroy_extension
      #do nothing - we want to keep these accounts around to know they're blocked.
    end
    
  end
end
