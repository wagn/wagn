# -*- encoding : utf-8 -*-
class Card
  Format.register :rss

  class RssFormat < HtmlFormat

    def internal_url relative_path
      wagn_url relative_path
    end
  end
end
