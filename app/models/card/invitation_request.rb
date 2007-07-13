module Card
  class InvitationRequest < Base
    attr_accessor :email

    before_validation_on_create :create_user
    before_destroy :block_user
    
    def create_user
      self.extension = ::User.new :email=> email
      extension.generate_password         
      extension.save
      extension.errors.each do |attr,msg| self.errors.add(attr,msg) end
      return false unless extension.valid?
    end
    
    def block_user
      extension.update_attributes :status=>'blocked'
    end

    def landing_name
      ::Setting.find_by_codename('invitation_request_landing').card.name
    end
      
    
    class << self
      # override permissions, since anonymous users must be able to create cards
      def permit_create?() true end       
    end
    def permit_destroy?() System.ok?(:deny_invitation_requests) end
    def permit_edit?()  false end
                         
    def post_render( content )
      content.replace content 
    end
    
  end
end
