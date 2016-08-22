# -*- encoding : utf-8 -*-
class Card
  class Format
    register :csv
    class CsvFormat < TextFormat
    end
  end
end
