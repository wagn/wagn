# -*- encoding : utf-8 -*-
class Card::CssFormat < Card::Format
  def initialize card, opts
    super card, opts
    if r = controller.response
      r.headers["Cache-Control"] = "public"
    end
  end
end
