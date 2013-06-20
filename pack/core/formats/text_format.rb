# -*- encoding : utf-8 -*-

class Card::TextFormat < Card::Format
    def initialize card, opts
      super card,opts

      if @format=='css' && controller
        controller.response.headers["Cache-Control"] = "public"
      end
    end
end
