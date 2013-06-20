# -*- encoding : utf-8 -*-
class Card::RssFormat < Card::HtmlFormat

  def internal_url relative_path
    wagn_url relative_path
  end

end
