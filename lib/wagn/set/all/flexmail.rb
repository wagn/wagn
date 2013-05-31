# -*- encoding : utf-8 -*-
module Wagn
  module Set::All::Flexmail
    include Sets

    action :flexmail, :after=>:commit do |args|
      Flexmail.mail_for self
    end
  end
end

class Flexmail
  class << self
    def configs_for card
      email_config_cardnames(card).map do |email_config|
        config = {}

        [:to, :from, :cc, :bcc, :attach].each do |field|
          config[field] = ( fld_card=Card["#{email_config}+*#{field}"] ).nil? ? '' :
              # configuration can be anything visible to configurer
              Account.as( fld_card.updater ) do
                list = fld_card.extended_list card
                field == :attach ? list : list * ','
              end
        end

        [:subject, :message].each do |field|
          config[field] = ( fld_card=Card["#{email_config}+*#{field}"] ).nil? ? '' :
              Account.as( fld_card.updater ) do
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
      Account.as_bot { event_card.item_names }
    end

    def mail_for card
      configs_for(card).map do |config|
        Mailer.flexmail config
      end.compact.each(&:deliver)
    end

    def strip_html string
      string.gsub(/<\/?[^>]*>/, "")
    end
  end
end