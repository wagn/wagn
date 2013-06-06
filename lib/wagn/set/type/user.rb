# -*- encoding : utf-8 -*-
module Wagn
  module Set::Type::User
    #extend Wagn::Set

    module Model
      include Wagn::Set::Type::Basic::Model

      attr_accessor :email

    end
  end
end
