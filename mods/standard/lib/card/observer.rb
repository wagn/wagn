# -*- encoding : utf-8 -*-

class Card
  class Observer

    class << self
    
      def send_timer_mails interval   
        Card.search( :right => Card[interval].name ).map(&:item_names).flatten.each do |cardname|
          deliver(cardname)
        end
      end

      def send_event_mails card, args        
        rule = "on_#{args[:on]}"    
        email_templates_for(card, rule) do |cardname|
          deliver( cardname )
        end
      end
      
      def deliver mail_cardname
        Card::Mailer.flexmail( config_for(mail_cardname) ).deliver
      end
      
      def config_for mail_cardname
        config = {}

        [:to, :from, :cc, :bcc, :attach].each do |field|
          config[field] = ( fld_card=Card["#{mail_cardname}+*#{field}"] ).nil? ? '' :
              # configuration can be anything visible to configurer
              Auth.as( fld_card.updater ) do
                list = fld_card.extended_list card
                field == :attach ? list : list * ','
              end
        end

        [:subject, :message].each do |field|
          config[field] = ( fld_card=Card["#{mail_cardname}+*#{field}"] ).nil? ? '' :
              Auth.as( fld_card.updater ) do
                fld_card.contextual_content card, :format=>'email_html'
              end
        end

        config[:subject] = strip_html(config[:subject]).strip
        config
      end
      
      def email_templates_for card, rule
        event_card = card.rule_card rule  #FIXME is this really a rule?
        return unless event_card
        #Auth.as_bot { event_card.item_names }   #TODO this is the old line. Why as_bot used here?
        Auth.as_bot do
          event_card.item_names.each do |name|
            yield(name)
          end
        end
      end

      
      def strip_html string
        string.gsub(/<\/?[^>]*>/, "")
      end
      
    end
    
  end
end
