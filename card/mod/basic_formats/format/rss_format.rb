# -*- encoding : utf-8 -*-
class Card
  class Format
    class RssFormat < HtmlFormat
      register :rss

      def internal_url relative_path
        card_url relative_path
      end
    end
  end
end
