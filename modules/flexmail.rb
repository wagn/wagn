module Flexmail
  class << self
    def expand_list_setting setting_card, context_card
      User.as(:wagbot) do
        case setting_card.type
          when "Pointer"
            setting_card.pointees.map do |cardname|
              CachedCard.get( cardname ).content
            end
          when "Search"
            setting_card.search( :limit=>"", :_card=>context_card ).map do |card|
              card.content
            end
          else 
            setting_card.content.split("\n")
        end
      end
    end
    
    def expand_content_setting setting_card, context_card
      context_card.content = setting_card.content
      s=Slot.new(context_card);
      # FIXME: maybe slot.rb should have an additional view for this.
      # ultimately we need to be able to process links and inclusions in an email/text friendly way
      s.expand_inclusions(s.render(:naked_content))
    end
  end  
end

Wagn::Hook.add :after_create, '*all' do |created_card|
  if send_config = created_card.setting_card("*send")
    email_config_cards = send_config.pointees.map { |name| CachedCard.get_real(name) }
    email_config_cards.each do |email_config_card|
      Mailer.deliver_flexmail created_card, email_config_card
    end
  end
end
  

  # mailer method
=begin SKETCH  
  module MailerMethods
    def flexmail created_card, config_card
      config = {}
      %w[to from bcc subject message].each do |item|
        raw_value = CachedCard.get("#{config_card.name}+*#{item}").content
        config[item] = Slot.render_content( raw_value, :card=>created_card )
      end

      recipients  config["to"]
      from        config["from"]
      bcc         config["bcc"]
      subject     config["subject"]
      body  :content => config["message"]
    end
  end

  Mailer.send :include, MailerMethods
=end

