# -*- encoding : utf-8 -*-

class Card
  class Flexmail

    class << self
      
      def configs_for card
        email_config_cardnames(card).map do |email_config|
          config = {}

          [:to, :from, :cc, :bcc, :attach].each do |field|
            config[field] = ( fld_card=Card["#{email_config}+*#{field}"] ).nil? ? '' :
                # configuration can be anything visible to configurer
                Auth.as( fld_card.updater ) do
                  list = fld_card.extended_list card
                  field == :attach ? list : list * ','
                end
          end

          [:subject, :message].each do |field|
            config[field] = ( fld_card=Card["#{email_config}+*#{field}"] ).nil? ? '' :
                Auth.as( fld_card.updater ) do
                  fld_card.contextual_content card, :format=>'email_html'
                end
          end

          config[:subject] = strip_html(config[:subject]).strip
          config
        end
      end

      def email_config_cardnames card
        #warn "card is #{card.inspect}"
        event_card = card.rule_card :send
        return [] unless event_card
        Auth.as_bot { event_card.item_names }
      end

      def mail_for card
        configs_for(card).map do |config|
          Card::Mailer.flexmail config
        end.compact.each(&:deliver)
      end

      def strip_html string
        string.gsub(/<\/?[^>]*>/, "")
      end
      
    end
    
  end
end
