# -*- encoding : utf-8 -*-

class Card
  Format.register :text
  class TextFormat < Format
    @@aliases[:txt] = :text
  end
end
