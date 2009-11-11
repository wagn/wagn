module Card
  class User < Basic
    attr_accessor :email

    def queries
      super<< 'revised_by'
    end
    
    def codename
      extension ? extension.login : nil
    end
         
  end  
end