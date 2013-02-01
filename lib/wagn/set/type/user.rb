module Wagn
  module Set::Type::User
    #include Wagn::Sets

    module Model
      include Wagn::Set::Type::Basic::Model

      attr_accessor :email

    end
  end
end
