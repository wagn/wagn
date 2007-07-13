module Card
  class User < Base
    attr_accessor :email

    def queries
      super<< 'revised_by'
    end
    
    def codename                       
      # FIXME: why do we have User cards without etensions?
      extension ? extension.login : nil
    end
         
    def permit_destroy?
      false
    end
=begin    
    before_validation_on_create :create_extension

    def create_extension                                   
      return if email.blank?
      self.extension = ::User.new :email=>email, :invite_sender=> ::User.current_user || ::User.find_by_login('anonymous')
      extension.generate_password
      extension.save
      extension.errors.each do |attr,msg| self.errors.add(attr,msg) end
      return false unless extension.valid?
    end
=end

  end  
end