# -*- encoding : utf-8 -*-

class Card
  class Format
    register :text
    register :txt

    class TextFormat < Format
      @@aliases["txt"] = "text"
    end
  end
end
