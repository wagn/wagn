# -*- encoding : utf-8 -*-

class Card
  class Format
    class TextFormat < Format
      register :text
      register :txt
      aliases["txt"] = "text"
    end
  end
end
