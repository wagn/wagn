module Card::User
  include Card::Basic

  attr_accessor :email
  
  def codename
    extension ? extension.login : nil
  end
       
end
