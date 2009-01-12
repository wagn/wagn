module Card
  class InvitationRequest < Basic
    attr_accessor :email

    before_validation_on_create :create_user
    before_destroy :block_user
    def landing_name
      ::Setting.find_by_codename('invitation_request_landing').card.name
    end
      
    def cacheable?
      false
    end

    private
    def create_user
      self.extension = ::User.new :email=> email
      extension.generate_password         
      extension.save
      extension.errors.each do |attr,msg| self.errors.add(attr,msg) end
      return false unless extension.valid?
    end
    
    def block_user
      if extension
        extension.update_attributes :status=>'blocked'
      end
    end
    
  end
end
