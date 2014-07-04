
class << self
  def send_timer_mails interval   
    Card.search( :right => Card[interval].name ).map(&:item_cards).flatten.each do |card|
      card.deliver
    end
  end
end



def send_event_mails args  
  setting = "on_#{args[:on]}".to_sym    
  email_templates_for( setting ) do |mailcard|
    mailcard.deliver( context: self)
  end
end

def email_templates_for setting
  if event_card = self.rule_card(setting)
    event_card.extended_item_cards.each do |mailcard|
      yield(mailcard)
    end
  end
end

[:create, :update, :delete, :save].each do |action|
  event "observer_#{action}".to_sym, :after=>:approve, :on=>action do 
    self.send_event_mails :on=>action
  end
end

event :observer_action, :after=>:approve do 
  self.send_event_mails :on=>:action
end

