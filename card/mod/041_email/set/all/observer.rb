def send_action_mails args
  setting = "on_#{args[:on]}".to_sym
  email_templates_for(setting) do |mailcard|
    mailcard.deliver(context: self)
  end
end

def email_templates_for setting
  if (email_templates = @email_template_cache ||
      ((event_card = rule_card(setting)) && event_card.extended_item_cards))
    email_templates.each do |mailcard|
      yield(mailcard)
    end
  end
end

[:create, :update, :delete].each do |action|
  event "observer_#{action}".to_sym, :integrate, on: action do
    send_action_mails on: action
  end
end

event :cache_delete_email_templates, :store, on: :delete do
  event_card = rule_card(:on_delete)
  @email_template_cache = event_card && event_card.extended_item_cards
end
