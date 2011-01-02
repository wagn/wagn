module Card
  class User < Basic
    attr_accessor :email
    
    def codename
      extension ? extension.login : nil
    end
         
  end  
end