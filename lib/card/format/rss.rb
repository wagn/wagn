# -*- encoding : utf-8 -*-
class Card
  class Format::Rss < Format::Html

    def internal_url relative_path
      wagn_url relative_path
    end

  end
end
