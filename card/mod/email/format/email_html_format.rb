# -*- encoding : utf-8 -*-
class Card
  class Format
    class EmailHtmlFormat < Card::Format::HtmlFormat
      @@aliases["email"] = "email_html"

      def internal_url relative_path
        card_url relative_path
      end
    end
  end
end
