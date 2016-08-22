# -*- encoding : utf-8 -*-
class Card
  class Format
    register :rss
    class RssFormat < HtmlFormat
      def internal_url relative_path
        card_url relative_path
      end
    end
  end
end
