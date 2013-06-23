# -*- encoding : utf-8 -*-
class Card::CssFormat < Card::TextFormat
  def initialize card, opts
    super card, opts
    controller.response.headers["Cache-Control"] = "public"
  end
end
