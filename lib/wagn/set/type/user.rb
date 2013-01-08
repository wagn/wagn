module Wagn
  module Set
    module Type
      module User
        #include Wagn::Sets

        module Model
          include Wagn::Set::Type::Basic::Model

          attr_accessor :email

        end
      end
    end
  end
end
