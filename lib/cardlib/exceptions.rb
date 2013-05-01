# -*- encoding : utf-8 -*-
module Cardlib::Exceptions
  class PermissionDenied < Wagn::PermissionDenied
    attr_reader :card
    def initialize(card)
      @card = card
      super build_message
    end

    def build_message
      "for card #{@card.name}: #{@card.errors[:permission_denied]}"
    end
  end
end

