class Card::User < Card::Basic
  attr_accessor :email
  
  def codename
    extension ? extension.login : nil
  end
       
end
