# -*- encoding : utf-8 -*-
require "open-uri"

class Card
  class Mailer < ActionMailer::Base
    @@defaults = Card.config.email_defaults || {}
    @@defaults.symbolize_keys!
    @@defaults[:return_path] ||= @@defaults[:from] if @@defaults[:from]
    @@defaults[:charset] ||= "utf-8"
    default @@defaults

    class << self
      def new_mail *args, &block
        mail = Mail.new(args, &block)
        method = Card::Mailer.delivery_method
        mail.delivery_method(method, Card::Mailer.send(:"#{method}_settings"))
        mail.perform_deliveries    = Card::Mailer.perform_deliveries
        mail.raise_delivery_errors = Card::Mailer.raise_delivery_errors
        mail
      end

      def layout message
        <<-HTML
          <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
          <html>
            <head>
              <meta http-equiv="Content-type" content="text/html;charset=UTF-8"/>
            </head>
            <body>
              #{message}
            </body>
          </html>
         HTML
      end
    end
  end
end
