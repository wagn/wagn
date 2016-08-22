# -*- encoding : utf-8 -*-
class Card
  class Format
    Format.register :json
    class JsonFormat < DataFormat
    end
  end
end
