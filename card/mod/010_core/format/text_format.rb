# -*- encoding : utf-8 -*-

class Card
  Format.register :text
  Format.register :txt

  class TextFormat < Format
    @@aliases["txt"] = "text"
  end
end
