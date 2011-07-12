class Flexmail
  class << self
    def configs_for card
      email_config_cardnames(card).map do |email_config|
        config = {}
        
        [:to, :from, :cc, :bcc, :attach].each do |field|
          config[field] = if_card("#{email_config}+*#{field}") do |c|
            # configuration can be anything visible to configurer
            User.as( c.updater ) do
              x = c.extended_list(card)
              field == :attach ? x : x.join(",")
            end
          end.else("")
        end
        
        [:subject, :message].each do |field|
          config[field] = if_card("#{email_config}+*#{field}") do |c|
            User.as( c.updater ) do
              c.contextual_content(card, :format=>'email_html')
            end
          end.else("")
        end
        
        config[:subject] = strip_html(config[:subject]).strip
        config
      end
    end
    
    def email_config_cardnames card
      event_card = card.setting_card('send')
      return [] unless event_card
      event_card.after_fetch
      User.as(:wagbot){ event_card.item_names }
    end
    
    def deliver_mail_for card
      configs_for(card).each do |config|
        ActiveRecord::Base.logger.warn "Sending mailconfig: #{config.inspect}"
        Mailer.deliver_flexmail config
      end
    end
    
    def strip_html string
      string.gsub(/<\/?[^>]*>/,  "")
    end
  end  


  # skip templated cards in create and handle them after multi-create,
  # so we have access to plus cards.
  Wagn::Hook.add :after_create, '*all' do |card|
    if !card.hard_template
      Flexmail.deliver_mail_for card
    end
  end

  Wagn::Hook.add :after_multi_create, '*all' do |card|
    if card.hard_template
      Flexmail.deliver_mail_for card
    end
  end
  
  # The Mailer method and mail template are defined in the standard rails locations
  # They can/should be brought out to more modular space if/when modules support adding
  # view/mail templates. 
end
