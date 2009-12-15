Wagn::Hook::Card.register :after_create, "*all" do |created_card|
  if send_config = created_card.setting_card("*send")
    pointee_cards = send_config.pointees.map { |name| CachedCard.get_real(name) }
    pointee_cards.each do |email_config_card|
      Mailer.deliver_flexmail created_card, email_config_card
    end
  end
end


module FlexmailMethods
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

Mailer.send :include, FlexmailMethods
