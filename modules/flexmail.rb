class Flexmail
  class << self
    def configs_for card
      if send_card = card.setting_card('send')
        items = User.as(:wagbot){ send_card.item_names }
        items.map do |email_config|
          config = {}
          
          [:to, :from, :cc, :bcc, :attach].each do |field|
            config[field] = if_card("#{email_config}+*#{field}") do |c|
              # configuration can be anything visible to configurer
              User.as( c.card.updater ) do
                x = c.extended_list(card)
                field == :attach ? x : x.join(",")
              end
            end.else("")
          end
          
          [:subject, :message].each do |field|
            config[field] = if_card("#{email_config}+*#{field}") do |c|
              User.as( c.card.updater ) do
                c.contextual_content(card)
              end
            end.else("")
          end
          
          config[:subject] = strip_html(config[:subject]).strip
          config
        end
      else
        []
      end
    end
    
    def deliver_mail_for(card)
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
