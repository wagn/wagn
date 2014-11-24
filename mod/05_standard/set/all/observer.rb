def send_action_mails args  
  setting = "on_#{args[:on]}".to_sym    
  email_templates_for( setting ) do |mailcard|
    mailcard.format(:format=>:email).deliver( context: self)
  end
end

def email_templates_for setting
  if event_card = self.rule_card(setting)
    event_card.extended_item_cards.each do |mailcard|
      yield(mailcard)
    end
  end
end

[:create, :update, :delete].each do |action|
  event "observer_#{action}".to_sym, :after=>:approve, :on=>action do 
    self.send_action_mails :on=>action
  end
end

