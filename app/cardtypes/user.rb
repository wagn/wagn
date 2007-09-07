module Card
  class User < Base
    set_editor_type "User"
    
    attr_accessor :email
    before_destroy :destroy_extension

    def queries
      super<< 'revised_by'
    end
    
    def codename                       
      # FIXME: why do we have User cards without etensions?
      extension ? extension.login : nil
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
     
    protected
    def destroy_extension
      self.extension.destroy
    end
    
    def validate_destroy
      if extension and Revision.find_by_created_by( extension.id )
        errors.add :destroy, "Edits have been made by this user"
      end
    end

  end  
end