# -*- encoding : utf-8 -*-

class Card::EmailHtmlFormat < Card::HtmlFormat
  def internal_url relative_path
    wagn_url relative_path
  end
end
