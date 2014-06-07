# -*- encoding : utf-8 -*-

class Card
  class Observer

    class << self
    
      def send_timer_mails interval   
        Card.search( :right => Card[interval].name ).map(&:item_cards).flatten.each do |card|
          deliver( card )
        end
      end

      def send_event_mails card, args        
        setting = "on_#{args[:on]}"    
        email_templates_for( card, setting ) do |card|
          deliver( card )
        end
      end
      
      def deliver mailcard
        mailcard.format(:format=>:email)._render_mail.deliver
      end
      
      def email_templates_for card, setting
        if event_card = card.rule_card( setting )
          event_card.item_cards.each do |mailcard|
            yield(mailcard)
          end
        end
      end

      def strip_html string
        string.gsub(/<\/?[^>]*>/, "")
      end
      
    end
  end
end
