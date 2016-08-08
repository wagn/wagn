# -*- encoding : utf-8 -*-

class Card::EmailHtmlFormat < Card::HtmlFormat
  @@aliases["email"] = "email_html"

  def internal_url relative_path
    card_url relative_path
  end
end
