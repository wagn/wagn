class Flexmail
  class << self
    def configs_for card
      email_config_cardnames(card).map do |email_config|
        config = {}

        [:to, :from, :cc, :bcc, :attach].each do |field|
          config[field] = if_card("#{email_config}+*#{field}") do |c|
            # configuration can be anything visible to configurer
            Account.as( c.updater ) do
              x = c.extended_list(card)
              field == :attach ? x : x.join(",")
            end
          end.else("")
        end

        [:subject, :message].each do |field|
          config[field] = if_card("#{email_config}+*#{field}") do |c|
            Account.as( c.updater ) do
              c.contextual_content(card, :format=>'email_html')
            end
          end.else("")
        end

        config[:subject] = strip_html(config[:subject]).strip
        config
      end
    end

    def email_config_cardnames card
      #warn "card is #{card.inspect}"
      event_card = card.rule_card(:send)
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

  Wagn::Hook.add :after_create, '*all' do |card|
    Flexmail.mail_for(card)
  end

  # The Mailer method and mail template are defined in the standard rails locations
  # They can/should be brought out to more modular space if/when modules support adding
  # view/mail templates.
end
