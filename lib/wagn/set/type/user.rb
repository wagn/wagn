module Wagn::Set::Type::User
  include Wagn::Set::Type::Basic

  attr_accessor :email
  
=begin
  def codename
    extension ? extension.login : nil
  end
=end
       
end
