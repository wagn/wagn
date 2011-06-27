module Wagn::Model::Type::User
  include Wagn::Model::Type::Basic

  attr_accessor :email
  
  def codename
    extension ? extension.login : nil
  end
       
end
