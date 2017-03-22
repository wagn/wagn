# -*- encoding : utf-8 -*-

class Card
  class Format
    class EmailTextFormat < Card::Format::TextFormat
      def internal_url relative_path
        card_url relative_path
      end

      def chunk_list
        :references
      end
    end
  end
end
