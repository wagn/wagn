# -*- encoding : utf-8 -*-

class Card
  class Error < StandardError # code problem
    cattr_accessor :current
  end

  class Oops < Error # wagneer problem (rename!)
  end

  class BadQuery < Error
  end

  class NotFound < StandardError
  end

  class PermissionDenied < Error
    attr_reader :card

    def initialize card
      @card = card
      super build_message
    end

    def build_message
      if msg = @card.errors[:permission_denied]
        "for card #{@card.name}: #{msg}"
      else
        super
      end
    end
  end

  class Abort < StandardError
    attr_reader :status

    def initialize status, msg=""
      @status = status
      super msg
    end
  end
end
