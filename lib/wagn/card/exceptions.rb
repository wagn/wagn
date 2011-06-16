module Wagn::Card::Exceptions
  class PermissionDenied < Wagn::Exceptions::PermissionDenied
    attr_reader :card
    def initialize(card)
      @card = card
      super build_message 
    end    

    def build_message
      "for card #{@card.name}: #{@card.errors.on(:permission_denied)}"
    end
  end
end

